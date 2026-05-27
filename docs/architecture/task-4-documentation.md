# Task 4 Documentation as Code

Documentation is kept in version control with the same review process as application and infrastructure code.

## Documents

- `docs/architecture/task-0-application.md`: application design and request flow.
- `docs/architecture/task-1-infrastructure.md`: AWS infrastructure design, Terraform layout, environment parameter injection, naming/tagging, state backend, and secret handling.
- `docs/architecture/task-2-pipeline.md`: CI/CD pipeline design, enterprise security baseline, environment selection, ECR packaging, Terraform deployment, and required GitHub configuration.
- `docs/architecture/task-3-policy.md`: OPA policy design, common policy rules, environment-specific gates, policy input structure, and local policy commands.
- `infra/terraform/README.md`: operator-focused Terraform commands, state bootstrap, naming/tagging, CI/CD variable mapping, and validation steps.
- `README.md`: repository overview and assignment mapping.

## Diagram Format

Diagrams use Mermaid so they can render directly in GitHub Markdown and remain reviewable as text.

## Documentation Update Rules

Design documents must change with the code they describe. Changes to Terraform modules, CI/CD workflow behavior, OPA policy structure, environment configuration, naming conventions, tags, state management, or secret handling should update the matching architecture document in the same commit.

## Verification

Documentation updates are verified with the same lightweight repository checks used for code changes:

- OPA policy tests confirm policy examples remain valid.
- Workflow YAML parsing confirms CI/CD examples remain syntactically valid.
- Terraform validation confirms infrastructure examples still match the module contract.
- `git diff --check` catches Markdown whitespace issues.
