package platform.environments.test

import rego.v1

valid_input := {
  "selected_environment": "test",
  "jobs": {
    "security-scan": {},
    "deploy": {
      "environment": "${{ inputs.environment }}",
      "needs": ["package-images", "policy-environment", "security-scan", "terraform-validate"],
    },
  },
}

test_test_policy_accepts_test_deployment if {
  count(deny) == 0 with input as valid_input
}

test_test_policy_requires_security_scan if {
  deny["test deployments must depend on security-scan"] with input as {
    "selected_environment": "test",
    "jobs": {
      "deploy": {
        "environment": "${{ inputs.environment }}",
        "needs": ["package-images", "policy-environment", "terraform-validate"],
      },
    },
  }
}
