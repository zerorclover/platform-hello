package platform.common

import rego.v1

deny contains msg if {
  lower(object.get(object.get(input, "permissions", {}), "id-token", "")) == "write"
  msg := "workflow must not grant id-token: write globally"
}

deny contains msg if {
  lower(object.get(object.get(input, "permissions", {}), "contents", "")) != "read"
  msg := "workflow must grant read-only contents permission globally"
}

deny contains msg if {
  some job_name
  job := input.jobs[job_name]
  not object.get(job, "timeout-minutes", false)
  msg := sprintf("%s must declare timeout-minutes", [job_name])
}

deny contains msg if {
  some job_name
  some step_index
  step := input.jobs[job_name].steps[step_index]
  is_checkout_step(step)
  not disables_persisted_credentials(step)
  msg := "checkout steps must disable persisted credentials"
}

deny contains msg if {
  some job_name
  job := input.jobs[job_name]
  uses_aws_credentials(job)
  lower(object.get(object.get(job, "permissions", {}), "id-token", "")) != "write"
  msg := sprintf("%s uses AWS credentials and must declare job-level id-token: write", [job_name])
}

deny contains msg if {
  some job_name
  job := input.jobs[job_name]
  is_deployment_job(job_name)
  not job_needs(job, "policy-environment")
  msg := sprintf("%s must depend on policy-environment", [job_name])
}

deny contains msg if {
  job := input.jobs["policy-environment"]
  not job_needs(job, "policy-common")
  msg := "policy-environment must depend on policy-common"
}

deny contains msg if {
  not has_secret_scan
  msg := "pipeline must include a secret scanning step"
}

deny contains msg if {
  not has_ecr_image_publish
  msg := "pipeline must publish environment-scoped images to ECR before deployment"
}

deny contains msg if {
  job := input.jobs.deploy
  not declares_environment(job)
  msg := "deploy must declare a GitHub environment for approval"
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

uses_aws_credentials(job) if {
  some step_index
  step := job.steps[step_index]
  uses := object.get(step, "uses", "")
  contains(lower(uses), "aws-actions/configure-aws-credentials")
}

is_checkout_step(step) if {
  uses := object.get(step, "uses", "")
  lower(uses) == "actions/checkout@v4"
}

disables_persisted_credentials(step) if {
  options := object.get(step, "with", {})
  object.get(options, "persist-credentials", true) == false
}

disables_persisted_credentials(step) if {
  options := object.get(step, "with", {})
  lower(object.get(options, "persist-credentials", "")) == "false"
}

is_deployment_job(job_name) if {
  job_name == "deploy"
}

is_deployment_job(job_name) if {
  job_name == "prepare-environment"
}

job_needs(job, dependency) if {
  needs := object.get(job, "needs", [])
  is_array(needs)
  needs[_] == dependency
}

job_needs(job, dependency) if {
  object.get(job, "needs", "") == dependency
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
