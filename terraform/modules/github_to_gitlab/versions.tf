terraform {
  required_providers {
    jenkins = {
      source  = "taiidani/jenkins"
      version = "~> 0.9"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}
