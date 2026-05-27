package platform.pipeline

import rego.v1

test_valid_pipeline_has_no_denies if {
  count(deny) == 0 with input as {
    "jobs": {
      "secret-scan": {
        "steps": [{"uses": "gitleaks/gitleaks-action@v2"}]
      },
      "package-images": {
        "steps": [
          {"uses": "aws-actions/amazon-ecr-login@v2"},
          {"uses": "docker/build-push-action@v6", "with": {"push": true}}
        ]
      },
      "deploy": {
        "environment": "staging",
        "needs": ["package-images"],
        "steps": [{"run": "terraform apply"}]
      }
    }
  }
}

test_missing_secret_scan_is_denied if {
  deny["pipeline must include a secret scanning step"] with input as {
    "jobs": {
      "deploy-staging": {
        "environment": "staging",
        "steps": [{"run": "terraform apply"}]
      }
    }
  }
}

test_missing_deploy_environment_is_denied if {
  deny["deploy must declare a GitHub environment for approval"] with input as {
    "jobs": {
      "secret-scan": {
        "steps": [{"uses": "gitleaks/gitleaks-action@v2"}]
      },
      "package-images": {
        "steps": [
          {"uses": "aws-actions/amazon-ecr-login@v2"},
          {"uses": "docker/build-push-action@v6", "with": {"push": true}}
        ]
      },
      "deploy": {
        "needs": ["package-images"],
        "steps": [{"run": "terraform apply"}]
      }
    }
  }
}

test_missing_deploy_environment_object_name_is_denied if {
  deny["deploy must declare a GitHub environment for approval"] with input as {
    "jobs": {
      "secret-scan": {
        "steps": [{"uses": "gitleaks/gitleaks-action@v2"}]
      },
      "package-images": {
        "steps": [
          {"uses": "aws-actions/amazon-ecr-login@v2"},
          {"uses": "docker/build-push-action@v6", "with": {"push": true}}
        ]
      },
      "deploy": {
        "environment": {"name": ""},
        "needs": ["package-images"],
        "steps": [{"run": "terraform apply"}]
      }
    }
  }
}

test_missing_ecr_image_publish_is_denied if {
  deny["pipeline must publish environment-scoped images to ECR before deployment"] with input as {
    "jobs": {
      "secret-scan": {
        "steps": [{"uses": "gitleaks/gitleaks-action@v2"}]
      },
      "deploy": {
        "environment": "staging",
        "needs": ["package-images"],
        "steps": [{"run": "terraform apply"}]
      }
    }
  }
}

test_deploy_without_package_images_dependency_is_denied if {
  deny["deploy must depend on package-images"] with input as {
    "jobs": {
      "secret-scan": {
        "steps": [{"uses": "gitleaks/gitleaks-action@v2"}]
      },
      "package-images": {
        "steps": [
          {"uses": "aws-actions/amazon-ecr-login@v2"},
          {"uses": "docker/build-push-action@v6", "with": {"push": true}}
        ]
      },
      "deploy": {
        "environment": "staging",
        "steps": [{"run": "terraform apply"}]
      }
    }
  }
}
