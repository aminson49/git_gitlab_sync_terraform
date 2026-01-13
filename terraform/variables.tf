variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "gitlab_token" {
  description = "GitLab personal access token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub organization or username"
  type        = string
}

variable "gitlab_base_url" {
  description = "GitLab instance URL"
  type        = string
  default     = "https://gitlab.com"
}

variable "jenkins_webhook_url" {
  description = "Jenkins webhook endpoint URL"
  type        = string
}

variable "github_to_gitlab" {
  description = "GitHub to GitLab sync configuration"
  type = object({
    github_repo_name    = string
    github_repo_full    = string
    gitlab_project_path = string
  })
}

variable "gitlab_to_github" {
  description = "GitLab to GitHub sync configuration"
  type = object({
    github_repo_name    = string
    github_repo_full    = string
    gitlab_project_path = string
  })
}
