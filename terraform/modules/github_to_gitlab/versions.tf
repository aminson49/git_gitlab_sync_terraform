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
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
