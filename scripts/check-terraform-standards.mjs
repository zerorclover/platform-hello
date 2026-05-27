import fs from "node:fs";
import path from "node:path";

const repoRoot = process.cwd();
const terraformRoot = path.join(repoRoot, "infra", "terraform");

const taggableResources = new Set([
  "aws_cloudwatch_log_group",
  "aws_db_instance",
  "aws_db_subnet_group",
  "aws_dynamodb_table",
  "aws_ecr_repository",
  "aws_ecs_cluster",
  "aws_ecs_service",
  "aws_ecs_task_definition",
  "aws_eip",
  "aws_iam_role",
  "aws_internet_gateway",
  "aws_lb",
  "aws_lb_listener",
  "aws_lb_listener_rule",
  "aws_lb_target_group",
  "aws_nat_gateway",
  "aws_route_table",
  "aws_s3_bucket",
  "aws_secretsmanager_secret",
  "aws_security_group",
  "aws_subnet",
  "aws_vpc",
]);

const errors = [];

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === ".terraform") return [];
      return walk(fullPath);
    }
    return entry.isFile() && entry.name.endsWith(".tf") ? [fullPath] : [];
  });
}

function findResourceBlocks(content) {
  const blocks = [];
  const resourcePattern = /resource\s+"([^"]+)"\s+"([^"]+)"\s*\{/g;
  let match;

  while ((match = resourcePattern.exec(content)) !== null) {
    let depth = 1;
    let index = resourcePattern.lastIndex;

    while (index < content.length && depth > 0) {
      const char = content[index];
      if (char === "{") depth += 1;
      if (char === "}") depth -= 1;
      index += 1;
    }

    blocks.push({
      type: match[1],
      name: match[2],
      body: content.slice(resourcePattern.lastIndex, index - 1),
    });
  }

  return blocks;
}

for (const file of walk(terraformRoot)) {
  const relativePath = path.relative(repoRoot, file);
  const content = fs.readFileSync(file, "utf8");

  for (const resource of findResourceBlocks(content)) {
    if (taggableResources.has(resource.type) && !/\btags\s*=/.test(resource.body)) {
      errors.push(`${relativePath}: ${resource.type}.${resource.name} is missing tags`);
    }

    if (
      ["aws_lb", "aws_lb_target_group"].includes(resource.type) &&
      /\bname\s*=/.test(resource.body) &&
      !/short_name_prefix/.test(resource.body)
    ) {
      errors.push(`${relativePath}: ${resource.type}.${resource.name} must use short_name_prefix for AWS name limits`);
    }
  }

  if (relativePath.startsWith("infra/terraform/modules/")) {
    if (/variable\s+"name"/.test(content)) {
      errors.push(`${relativePath}: module variable "name" must be "name_prefix"`);
    }
    if (/\bvar\.name\b/.test(content)) {
      errors.push(`${relativePath}: module resources must use var.name_prefix or var.short_name_prefix`);
    }
  }
}

const platformStack = fs.readFileSync(path.join(terraformRoot, "stacks", "platform", "main.tf"), "utf8");
for (const required of ["name_prefix", "short_name_prefix", "common_tags"]) {
  if (!platformStack.includes(required)) {
    errors.push(`infra/terraform/stacks/platform/main.tf: missing local ${required}`);
  }
}

const envMain = fs.readFileSync(path.join(terraformRoot, "envs", "platform", "main.tf"), "utf8");
if (!/default_tags\s*\{/.test(envMain)) {
  errors.push("infra/terraform/envs/platform/main.tf: AWS provider must configure default_tags");
}

if (errors.length > 0) {
  console.error(errors.join("\n"));
  process.exit(1);
}

console.log("Terraform naming and tagging standards passed");
