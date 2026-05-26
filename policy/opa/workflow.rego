package platform.pipeline

import rego.v1

protected_environments := {"staging", "production"}

deny contains msg if {
  not has_secret_scan
  msg := "pipeline must include a secret scanning step"
}

deny contains msg if {
  some job_name
  job := input.jobs[job_name]
  is_protected_deploy_job(job_name)
  not declares_protected_environment(job)
  msg := sprintf("%s must declare a protected GitHub environment for approval", [job_name])
}

has_secret_scan if {
  some job_name
  some step_index
  step := input.jobs[job_name].steps[step_index]
  uses := object.get(step, "uses", "")
  contains(lower(uses), "gitleaks")
}

has_secret_scan if {
  some job_name
  some step_index
  step := input.jobs[job_name].steps[step_index]
  run := object.get(step, "run", "")
  contains(lower(run), "gitleaks")
}

is_protected_deploy_job(job_name) if {
  startswith(job_name, "deploy-")
  parts := split(job_name, "deploy-")
  env_name := parts[1]
  protected_environments[env_name]
}

declares_protected_environment(job) if {
  env_name := object.get(job, "environment", "")
  is_string(env_name)
  protected_environments[env_name]
}

declares_protected_environment(job) if {
  environment := object.get(job, "environment", {})
  env_name := object.get(environment, "name", "")
  protected_environments[env_name]
}
