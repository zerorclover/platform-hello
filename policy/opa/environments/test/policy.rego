package platform.environments.test

import rego.v1

deny contains msg if {
  input.selected_environment != "test"
  msg := "test policy can only evaluate test deployments"
}

deny contains msg if {
  job := input.jobs.deploy
  not job_needs(job, "security-scan")
  msg := "test deployments must depend on security-scan"
}

job_needs(job, dependency) if {
  needs := object.get(job, "needs", [])
  is_array(needs)
  needs[_] == dependency
}

job_needs(job, dependency) if {
  object.get(job, "needs", "") == dependency
}
