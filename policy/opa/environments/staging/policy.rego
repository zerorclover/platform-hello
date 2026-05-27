package platform.environments.staging

import rego.v1

deny contains msg if {
  input.selected_environment != "staging"
  msg := "staging policy can only evaluate staging deployments"
}

deny contains msg if {
  job := input.jobs["policy-environment"]
  not declares_selected_environment(job)
  msg := "staging policy gate must declare the selected GitHub environment"
}

declares_selected_environment(job) if {
  object.get(job, "environment", "") == "${{ inputs.environment }}"
}

declares_selected_environment(job) if {
  environment := object.get(job, "environment", {})
  object.get(environment, "name", "") == "${{ inputs.environment }}"
}
