# Terraform Infrastructure

This directory contains AWS infrastructure as code for `platform-hello`.

## Environments

- `dev`: small single-region environment for development.
- `test`: small single-region environment for internal QA.
- `perf`: performance test environment with production-like capacity knobs.
- `staging`: pre-production integration and UAT environment.
- `production`: production environment with stricter sizing and deletion protection defaults.

The root entry point is `infra/terraform/envs/platform`. Terraform exposes environment-specific values as variables. CI/CD supplies those values through `TF_VAR_*`, so the stack does not hard-code per-environment CIDR ranges, availability zones, task counts, ECS sizing, log retention, RDS sizing, backup retention, engine version, or deletion protection.

## Commands

Bootstrap the remote state backend once per AWS account:

```bash
cd infra/terraform/bootstrap/state-backend
terraform init
terraform apply \
  -var state_bucket_name=platform-hello-tfstate-<account-id> \
  -var lock_table_name=platform-hello-tf-locks
```

Then run the platform stack with remote state:

```bash
cd infra/terraform/envs/platform
terraform init \
  -backend-config="bucket=platform-hello-tfstate-<account-id>" \
  -backend-config="key=platform-hello/dev/terraform.tfstate" \
  -backend-config="region=$AWS_REGION" \
  -backend-config="dynamodb_table=platform-hello-tf-locks" \
  -backend-config="encrypt=true"
terraform fmt -recursive
terraform validate
TF_VAR_environment=dev \
TF_VAR_aws_region=$AWS_REGION \
TF_VAR_backend_image=111111111111.dkr.ecr.$AWS_REGION.amazonaws.com/platform-hello-dev-backend:latest \
TF_VAR_frontend_image=111111111111.dkr.ecr.$AWS_REGION.amazonaws.com/platform-hello-dev-frontend:latest \
TF_VAR_vpc_cidr=10.10.0.0/16 \
TF_VAR_availability_zones='["${AWS_REGION}a","${AWS_REGION}b"]' \
TF_VAR_db_name=platform \
TF_VAR_db_username=platform \
TF_VAR_db_instance_class=db.t4g.micro \
TF_VAR_desired_count=1 \
TF_VAR_deletion_protection=false \
TF_VAR_ecs_task_cpu=256 \
TF_VAR_ecs_task_memory=512 \
TF_VAR_log_retention_days=14 \
TF_VAR_db_engine_version=16.3 \
TF_VAR_db_allocated_storage=20 \
TF_VAR_db_backup_retention_days=7 \
terraform plan
```

In GitHub Actions, these same values are provided by repository variables for validation and by GitHub Environment variables for deployment.

Database credentials are generated with the Terraform `random` provider and exposed to ECS through AWS Secrets Manager. The application receives `DATABASE_URL` as an ECS secret, not as a plain task environment variable.

## State

The platform stack uses a partial S3 backend so account-specific backend values are supplied by CI/CD:

- `bucket`: `TF_STATE_BUCKET` GitHub Environment variable.
- `key`: `platform-hello/<environment>/terraform.tfstate`.
- `region`: `AWS_REGION` GitHub Environment variable.
- `dynamodb_table`: `TF_STATE_LOCK_TABLE` GitHub Environment variable.
- `encrypt`: `true`.

The bootstrap stack creates:

- An S3 bucket with versioning enabled.
- S3 server-side encryption using AES256.
- S3 public access block and bucket-owner-enforced ownership.
- A DynamoDB lock table with `LockID` hash key.
- DynamoDB server-side encryption and point-in-time recovery.
