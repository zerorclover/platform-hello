package platform.environments.staging

import rego.v1

valid_input := {
  "selected_environment": "staging",
  "jobs": {
    "deploy": {
      "environment": "${{ inputs.environment }}",
      "needs": ["package-images", "policy-environment", "security-scan", "terraform-validate"],
    },
    "policy-environment": {
      "environment": "${{ inputs.environment }}",
    },
  },
}

test_staging_policy_accepts_staging_deployment if {
  count(deny) == 0 with input as valid_input
}

test_staging_policy_requires_environment_gate if {
  deny["staging policy gate must declare the selected GitHub environment"] with input as {
    "selected_environment": "staging",
    "jobs": {
      "deploy": valid_input.jobs.deploy,
      "policy-environment": {},
    },
  }
}
