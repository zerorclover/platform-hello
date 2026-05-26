package platform.pipeline

import rego.v1

test_valid_pipeline_has_no_denies if {
  count(deny) == 0 with input as {
    "jobs": {
      "secret-scan": {
        "steps": [{"uses": "gitleaks/gitleaks-action@v2"}]
      },
      "deploy-staging": {
        "environment": "staging",
        "steps": [{"run": "terraform apply"}]
      },
      "deploy-production": {
        "environment": {"name": "production"},
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

test_missing_staging_environment_is_denied if {
  deny["deploy-staging must declare a protected GitHub environment for approval"] with input as {
    "jobs": {
      "secret-scan": {
        "steps": [{"uses": "gitleaks/gitleaks-action@v2"}]
      },
      "deploy-staging": {
        "steps": [{"run": "terraform apply"}]
      }
    }
  }
}

test_missing_production_environment_is_denied if {
  deny["deploy-production must declare a protected GitHub environment for approval"] with input as {
    "jobs": {
      "secret-scan": {
        "steps": [{"uses": "gitleaks/gitleaks-action@v2"}]
      },
      "deploy-production": {
        "steps": [{"run": "terraform apply"}]
      }
    }
  }
}
