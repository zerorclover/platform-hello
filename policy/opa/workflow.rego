package platform.pipeline

import rego.v1

deny contains msg if {
  not has_secret_scan
  msg := "pipeline must include a secret scanning step"
}

deny contains msg if {
  not has_ecr_image_publish
  msg := "pipeline must publish environment-scoped images to ECR before deployment"
}

deny contains msg if {
  some job_name
  job := input.jobs[job_name]
  is_deploy_job(job_name)
  not job_needs(job, "package-images")
  msg := sprintf("%s must depend on package-images", [job_name])
}

deny contains msg if {
  some job_name
  job := input.jobs[job_name]
  is_deploy_job(job_name)
  not declares_environment(job)
  msg := sprintf("%s must declare a GitHub environment for approval", [job_name])
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

has_ecr_image_publish if {
  some job_name
  job := input.jobs[job_name]
  has_ecr_login(job)
  has_push_image_build(job)
}

has_ecr_login(job) if {
  some step_index
  step := job.steps[step_index]
  uses := object.get(step, "uses", "")
  contains(lower(uses), "aws-actions/amazon-ecr-login")
}

has_push_image_build(job) if {
  some step_index
  step := job.steps[step_index]
  uses := object.get(step, "uses", "")
  contains(lower(uses), "docker/build-push-action")
  step_push_enabled(step)
}

step_push_enabled(step) if {
  options := object.get(step, "with", {})
  object.get(options, "push", false) == true
}

step_push_enabled(step) if {
  options := object.get(step, "with", {})
  lower(object.get(options, "push", "")) == "true"
}

job_needs(job, dependency) if {
  needs := object.get(job, "needs", [])
  is_array(needs)
  needs[_] == dependency
}

job_needs(job, dependency) if {
  object.get(job, "needs", "") == dependency
}

is_deploy_job(job_name) if {
  job_name == "deploy"
}

is_deploy_job(job_name) if {
  startswith(job_name, "deploy-")
}

declares_environment(job) if {
  env_name := object.get(job, "environment", "")
  is_string(env_name)
  env_name != ""
}

declares_environment(job) if {
  environment := object.get(job, "environment", {})
  env_name := object.get(environment, "name", "")
  env_name != ""
}
