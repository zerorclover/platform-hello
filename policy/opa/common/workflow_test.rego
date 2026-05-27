package platform.common

import rego.v1

valid_workflow := {
  "permissions": {"contents": "read"},
  "jobs": {
    "secret-scan": {
      "timeout-minutes": 10,
      "steps": [
        {"uses": "actions/checkout@v4", "with": {"persist-credentials": false}},
        {"uses": "gitleaks/gitleaks-action@v2"},
      ],
    },
    "security-scan": {
      "timeout-minutes": 15,
      "steps": [
        {"uses": "actions/checkout@v4", "with": {"persist-credentials": false}},
        {"uses": "aquasecurity/trivy-action@0.24.0"},
      ],
    },
    "terraform-validate": {
      "timeout-minutes": 15,
      "steps": [
        {"uses": "actions/checkout@v4", "with": {"persist-credentials": false}},
        {"run": "terraform fmt -check -recursive"},
        {"run": "node scripts/check-terraform-standards.mjs"},
        {"run": "terraform validate"},
      ],
    },
    "policy-common": {
      "timeout-minutes": 10,
      "steps": [
        {"uses": "actions/checkout@v4", "with": {"persist-credentials": false}},
        {"run": "opa test policy/opa/common"},
      ],
    },
    "policy-environment": {
      "timeout-minutes": 10,
      "needs": ["policy-common"],
      "steps": [
        {"uses": "actions/checkout@v4", "with": {"persist-credentials": false}},
        {"run": "opa eval --data policy/opa/environments/${TARGET_ENV}"},
      ],
    },
    "prepare-environment": {
      "timeout-minutes": 20,
      "permissions": {"contents": "read", "id-token": "write"},
      "needs": ["docker-build", "secret-scan", "security-scan", "terraform-validate", "policy-common", "policy-environment"],
      "steps": [
        {"uses": "actions/checkout@v4", "with": {"persist-credentials": false}},
        {"uses": "aws-actions/configure-aws-credentials@v4"},
      ],
    },
    "package-images": {
      "timeout-minutes": 30,
      "permissions": {"contents": "read", "id-token": "write"},
      "needs": ["prepare-environment"],
      "steps": [
        {"uses": "actions/checkout@v4", "with": {"persist-credentials": false}},
        {"uses": "aws-actions/amazon-ecr-login@v2"},
        {"uses": "docker/build-push-action@v6", "with": {"push": true}},
      ],
    },
    "deploy": {
      "timeout-minutes": 30,
      "environment": "${{ inputs.environment }}",
      "permissions": {"contents": "read", "id-token": "write"},
      "needs": ["package-images", "policy-environment", "security-scan", "terraform-validate"],
      "steps": [
        {"uses": "actions/checkout@v4", "with": {"persist-credentials": false}},
        {"run": "terraform plan -input=false -out=tfplan"},
        {"run": "terraform apply -input=false -auto-approve tfplan"},
      ],
    },
  },
}

test_valid_enterprise_pipeline_has_no_denies if {
  count(deny) == 0 with input as valid_workflow
}

test_global_oidc_permission_is_denied if {
  deny["workflow must not grant id-token: write globally"] with input as object.union(valid_workflow, {
    "permissions": {"contents": "read", "id-token": "write"},
  })
}

test_global_contents_write_permission_is_denied if {
  deny["workflow must grant read-only contents permission globally"] with input as object.union(valid_workflow, {
    "permissions": {"contents": "write"},
  })
}

test_missing_job_timeout_is_denied if {
  deny["deploy must declare timeout-minutes"] with input as {
    "permissions": {"contents": "read"},
    "jobs": {
      "secret-scan": object.union(valid_workflow.jobs["secret-scan"], {"timeout-minutes": 10}),
      "policy-common": object.union(valid_workflow.jobs["policy-common"], {"timeout-minutes": 10}),
      "policy-environment": object.union(valid_workflow.jobs["policy-environment"], {"timeout-minutes": 10}),
      "package-images": object.union(valid_workflow.jobs["package-images"], {"timeout-minutes": 30}),
      "deploy": {
        "environment": "${{ inputs.environment }}",
        "permissions": {"contents": "read", "id-token": "write"},
        "needs": ["package-images", "policy-environment", "security-scan", "terraform-validate"],
        "steps": [
          {"uses": "actions/checkout@v4", "with": {"persist-credentials": false}},
          {"run": "terraform plan -input=false -out=tfplan"},
          {"run": "terraform apply -input=false -auto-approve tfplan"},
        ],
      },
    },
  }
}

test_checkout_persist_credentials_is_denied if {
  deny["checkout steps must disable persisted credentials"] with input as {
    "permissions": {"contents": "read"},
    "jobs": {
      "secret-scan": {
        "timeout-minutes": 10,
        "steps": [{"uses": "actions/checkout@v4"}],
      },
      "policy-common": object.union(valid_workflow.jobs["policy-common"], {"timeout-minutes": 10}),
      "policy-environment": object.union(valid_workflow.jobs["policy-environment"], {"timeout-minutes": 10}),
      "package-images": object.union(valid_workflow.jobs["package-images"], {"timeout-minutes": 30}),
      "deploy": object.union(valid_workflow.jobs.deploy, {"timeout-minutes": 30}),
    },
  }
}

test_aws_job_without_oidc_permission_is_denied if {
  deny["prepare-environment uses AWS credentials and must declare job-level id-token: write"] with input as {
    "permissions": {"contents": "read"},
    "jobs": {
      "secret-scan": valid_workflow.jobs["secret-scan"],
      "policy-common": valid_workflow.jobs["policy-common"],
      "policy-environment": valid_workflow.jobs["policy-environment"],
      "package-images": valid_workflow.jobs["package-images"],
      "deploy": valid_workflow.jobs.deploy,
      "prepare-environment": {
        "permissions": {},
        "needs": ["docker-build", "secret-scan", "security-scan", "terraform-validate", "policy-common", "policy-environment"],
        "steps": [{"uses": "aws-actions/configure-aws-credentials@v4"}],
      },
    },
  }
}

test_deploy_without_environment_policy_gate_is_denied if {
  workflow := object.union(valid_workflow, {
    "jobs": object.union(valid_workflow.jobs, {
      "deploy": object.union(valid_workflow.jobs.deploy, {
        "needs": ["package-images", "security-scan", "terraform-validate"],
      }),
    }),
  })

  deny["deploy must depend on policy-environment"] with input as workflow
}

test_policy_environment_without_common_gate_is_denied if {
  workflow := object.union(valid_workflow, {
    "jobs": object.union(valid_workflow.jobs, {
      "policy-environment": object.union(valid_workflow.jobs["policy-environment"], {
        "needs": [],
      }),
    }),
  })

  deny["policy-environment must depend on policy-common"] with input as workflow
}
