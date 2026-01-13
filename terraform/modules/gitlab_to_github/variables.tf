variable "github_repo_name" {
  type = string
}

variable "github_repo_full" {
  type = string
}

variable "gitlab_project_path" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}
