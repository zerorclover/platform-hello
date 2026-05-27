# Task 3 Policy as Code

## Overview

OPA policies live under `policy/opa`. They enforce required pipeline controls:

- The pipeline must include secret scanning.
- The pipeline must publish environment-scoped images to ECR before deployment.
- Deployment jobs must depend on the ECR image publishing job.
- Deployment jobs must declare a GitHub Environment, so repository settings can enforce approvals for protected environments such as staging and production.
- Runtime credentials must be provided by platform secret stores such as GitHub Actions secrets, local `.env` files ignored by Git, or AWS Secrets Manager.

## Policy Flow

```mermaid
flowchart LR
  Workflow[GitHub Actions workflow] --> Input[Normalized policy input]
  Input --> OPA[OPA policy evaluation]
  OPA --> Allow[No deny results]
  OPA --> Deny[Deny message blocks pipeline]
```

## Local Commands

If OPA is installed:

```bash
opa test policy/opa
opa eval --data policy/opa --input policy/opa/input/github_actions.json "data.platform.pipeline.deny"
```

## Required GitHub Settings

Configure these GitHub Environments:

- `staging`: require one or more reviewers.
- `production`: require one or more reviewers.

The workflow selects one of those environments from `workflow_dispatch.inputs.environment`; repository settings enforce the human approval gate.
