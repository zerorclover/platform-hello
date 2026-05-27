package platform.environments.production

import rego.v1

valid_input := {
  "selected_environment": "production",
  "jobs": {
    "deploy": {
      "environment": "${{ inputs.environment }}",
      "permissions": {"contents": "read", "id-token": "write"},
      "needs": ["package-images", "policy-environment", "security-scan", "terraform-validate"],
      "steps": [
        {"run": "terraform plan -input=false -out=tfplan"},
        {"run": "terraform apply -input=false -auto-approve tfplan"},
      ],
    },
    "policy-environment": {
      "environment": "${{ inputs.environment }}",
    },
  },
}

test_production_policy_accepts_production_deployment if {
  count(deny) == 0 with input as valid_input
}

test_production_policy_requires_plan_before_apply if {
  deny["production deploy must run terraform plan before terraform apply"] with input as {
    "selected_environment": "production",
    "jobs": {
      "deploy": object.union(valid_input.jobs.deploy, {
        "steps": [{"run": "terraform apply -input=false -auto-approve tfplan"}],
      }),
      "policy-environment": valid_input.jobs["policy-environment"],
    },
  }
}

test_production_policy_rejects_non_production_environment if {
  deny["production policy can only evaluate production deployments"] with input as object.union(valid_input, {
    "selected_environment": "staging",
  })
}
