package platform.environments.dev

import rego.v1

valid_input := {
  "selected_environment": "dev",
  "jobs": {
    "deploy": {
      "environment": "${{ inputs.environment }}",
      "needs": ["package-images", "policy-environment", "terraform-validate"],
    },
  },
}

test_dev_policy_accepts_dev_deployment if {
  count(deny) == 0 with input as valid_input
}

test_dev_policy_rejects_wrong_environment if {
  deny["dev policy can only evaluate dev deployments"] with input as object.union(valid_input, {
    "selected_environment": "test",
  })
}
