# Terraform Infrastructure

This directory contains AWS infrastructure as code for `platform-hello`.

## Environments

- `dev`: small single-region environment for development.
- `test`: small single-region environment for internal QA.
- `perf`: performance test environment with production-like capacity knobs.
- `staging`: pre-production integration and UAT environment.
- `production`: production environment with stricter sizing and deletion protection defaults.

The root entry point is `infra/terraform/envs/platform`. Terraform exposes environment-specific values as variables. CI/CD supplies those values through `TF_VAR_*`, so the stack does not hard-code per-environment CIDR ranges, availability zones, task counts, RDS sizing, or deletion protection.

## Commands

```bash
cd infra/terraform/envs/platform
terraform init
terraform fmt -recursive
terraform validate
TF_VAR_environment=dev \
TF_VAR_backend_image=111111111111.dkr.ecr.us-west-2.amazonaws.com/platform-hello-dev-backend:latest \
TF_VAR_frontend_image=111111111111.dkr.ecr.us-west-2.amazonaws.com/platform-hello-dev-frontend:latest \
TF_VAR_vpc_cidr=10.10.0.0/16 \
TF_VAR_availability_zones='["us-west-2a","us-west-2b"]' \
TF_VAR_db_name=platform \
TF_VAR_db_username=platform \
TF_VAR_db_instance_class=db.t4g.micro \
TF_VAR_desired_count=1 \
TF_VAR_deletion_protection=false \
terraform plan
```

In GitHub Actions, these same values are provided by matrix values for validation and by GitHub Environment variables for deployment.

Database credentials are generated with the Terraform `random` provider and exposed to ECS through AWS Secrets Manager. The application receives `DATABASE_URL` as an ECS secret, not as a plain task environment variable.

## State

Remote state is not hard-coded because backend bucket names and access policies should be created by the owning AWS account. For a real deployment, configure an S3 backend and DynamoDB lock table per account or per environment.
