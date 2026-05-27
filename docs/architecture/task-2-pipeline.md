# Task 2 Pipeline Design

## Overview

GitHub Actions is used as the accepted CI/CD platform. The workflow is defined in `.github/workflows/ci.yml`.

```mermaid
flowchart TD
  Checkout[Checkout] --> Tests[Backend unit tests]
  Checkout --> SecretScan[Secret scanning]
  Checkout --> SecurityScan[Filesystem security scan]
  Tests --> DockerBuild[Build frontend/backend images]
  Checkout --> Terraform[Terraform fmt/init/validate]
  Checkout --> OPA[OPA policy checks]
  DockerBuild --> Deploy{Manual workflow_dispatch}
  SecretScan --> Deploy
  SecurityScan --> Deploy
  Terraform --> Deploy
  OPA --> Deploy
  Deploy --> Dev[Deploy dev/test/perf]
  Deploy --> Stage[Deploy staging with environment approval]
  Deploy --> Prod[Deploy production with environment approval]
```

## Stages

- `backend-test`: runs Node.js unit tests.
- `secret-scan`: runs Gitleaks to block hard-coded credentials.
- `docker-build`: builds backend and frontend images without pushing on PRs.
- `security-scan`: runs Trivy filesystem scanning.
- `terraform-validate`: checks Terraform formatting and variable contract without embedding environment values.
- `policy`: runs OPA tests and evaluates the pipeline policy input.
- `deploy-*`: manual deployment jobs selected by `workflow_dispatch.inputs.environment`.

## Terraform Parameter Injection

Terraform environment settings are owned by CI/CD, not hard-coded inside Terraform:

- Validation checks Terraform syntax without embedding environment-specific values.
- Deployment uses GitHub Environment variables such as `AWS_REGION`, `VPC_CIDR`, `AVAILABILITY_ZONES_JSON`, `DB_INSTANCE_CLASS`, `DESIRED_COUNT`, and `DELETION_PROTECTION`.
- AWS identity and account values are read from GitHub Environment secrets.
- Terraform backend values are read from `TF_STATE_BUCKET` and `TF_STATE_LOCK_TABLE`, then passed to `terraform init` with `encrypt=true` and an environment-specific state key.

## Approval Model

The `deploy-staging` and `deploy-production` jobs declare GitHub Environments named `staging` and `production`. In a real repository, those environments should require reviewers in repository settings so GitHub blocks the deployment until approval is granted.
