package platform.environments.production

import rego.v1

deny contains msg if {
  input.selected_environment != "production"
  msg := "production policy can only evaluate production deployments"
}

deny contains msg if {
  job := input.jobs["policy-environment"]
  not declares_selected_environment(job)
  msg := "production policy gate must declare the selected GitHub environment"
}

deny contains msg if {
  job := input.jobs.deploy
  not terraform_plan_before_apply(job)
  msg := "production deploy must run terraform plan before terraform apply"
}

deny contains msg if {
  job := input.jobs.deploy
  lower(object.get(object.get(job, "permissions", {}), "id-token", "")) != "write"
  msg := "production deploy must use OIDC with job-level id-token: write"
}

declares_selected_environment(job) if {
  object.get(job, "environment", "") == "${{ inputs.environment }}"
}

declares_selected_environment(job) if {
  environment := object.get(job, "environment", {})
  object.get(environment, "name", "") == "${{ inputs.environment }}"
}

terraform_plan_before_apply(job) if {
  some plan_index
  some apply_index
  plan_step := job.steps[plan_index]
  apply_step := job.steps[apply_index]
  contains(lower(object.get(plan_step, "run", "")), "terraform plan")
  contains(lower(object.get(apply_step, "run", "")), "terraform apply")
  plan_index < apply_index
}
