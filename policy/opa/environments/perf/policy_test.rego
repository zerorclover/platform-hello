package platform.environments.perf

import rego.v1

valid_input := {
  "selected_environment": "perf",
  "jobs": {
    "deploy": {
      "environment": "${{ inputs.environment }}",
      "needs": ["package-images", "policy-environment", "security-scan", "terraform-validate"],
    },
    "package-images": {
      "strategy": {"matrix": {"component": ["backend", "frontend"]}},
    },
  },
}

test_perf_policy_accepts_perf_deployment if {
  count(deny) == 0 with input as valid_input
}

test_perf_policy_requires_both_images if {
  deny["perf deployments must build both backend and frontend images"] with input as {
    "selected_environment": "perf",
    "jobs": {
      "deploy": valid_input.jobs.deploy,
      "package-images": {"strategy": {"matrix": {"component": ["backend"]}}},
    },
  }
}
