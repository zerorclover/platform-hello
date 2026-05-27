package platform.environments.perf

import rego.v1

deny contains msg if {
  input.selected_environment != "perf"
  msg := "perf policy can only evaluate perf deployments"
}

deny contains msg if {
  not matrix_has_component(input.jobs["package-images"], "backend")
  msg := "perf deployments must build both backend and frontend images"
}

deny contains msg if {
  not matrix_has_component(input.jobs["package-images"], "frontend")
  msg := "perf deployments must build both backend and frontend images"
}

deny contains msg if {
  job := input.jobs.deploy
  not job_needs(job, "security-scan")
  msg := "perf deployments must depend on security-scan"
}

matrix_has_component(job, component) if {
  components := object.get(object.get(object.get(job, "strategy", {}), "matrix", {}), "component", [])
  components[_] == component
}

job_needs(job, dependency) if {
  needs := object.get(job, "needs", [])
  is_array(needs)
  needs[_] == dependency
}

job_needs(job, dependency) if {
  object.get(job, "needs", "") == dependency
}
