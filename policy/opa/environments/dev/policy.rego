package platform.environments.dev

import rego.v1

deny contains msg if {
  input.selected_environment != "dev"
  msg := "dev policy can only evaluate dev deployments"
}
