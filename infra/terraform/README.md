# Terraform Infrastructure

This directory contains AWS infrastructure as code for `platform-hello`.

## Environments

- `dev`: small single-region environment for development.
- `test`: small single-region environment for internal QA.
- `perf`: performance test environment with production-like capacity knobs.
- `staging`: pre-production integration and UAT environment.
- `production`: production environment with stricter sizing and deletion protection defaults.

The root entry point is `infra/terraform/envs/platform`. It uses one selector, `environment`, and the shared stack maps that selector to CIDR ranges, availability zones, task counts, RDS sizing, and deletion protection.

## Commands

```bash
cd infra/terraform/envs/platform
terraform init
terraform fmt -recursive
terraform validate
terraform plan \
  -var environment=dev \
  -var backend_image=111111111111.dkr.ecr.us-west-2.amazonaws.com/platform-hello-dev-backend:latest \
  -var frontend_image=111111111111.dkr.ecr.us-west-2.amazonaws.com/platform-hello-dev-frontend:latest \
  -var db_password="$DB_PASSWORD"
```

Use the same command with `environment=test`, `environment=perf`, `environment=staging`, or `environment=production` to select another environment without duplicating the parameter set.

## State

Remote state is not hard-coded because backend bucket names and access policies should be created by the owning AWS account. For a real deployment, configure an S3 backend and DynamoDB lock table per account or per environment.
