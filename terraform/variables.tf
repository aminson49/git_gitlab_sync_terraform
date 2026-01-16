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

variable "jenkins_url" {
  description = "Jenkins base URL (for job creation)"
  type        = string
}

variable "jenkins_username" {
  description = "Jenkins username (for job creation)"
  type        = string
}

variable "jenkins_api_token" {
  description = "Jenkins API token (for job creation)"
  type        = string
  sensitive   = true
}

variable "jenkins_job_enabled" {
  description = "Whether to create a Jenkins job for GitHub->GitLab sync"
  type        = bool
  default     = false
}

variable "jenkins_job_name" {
  description = "Jenkins job name for GitHub->GitLab sync"
  type        = string
  default     = "github-to-gitlab-sync"
}

variable "jenkins_job_branch" {
  description = "Branch to build in Jenkins job"
  type        = string
  default     = "*/main"
}

variable "jenkins_scm_credentials_id" {
  description = "Jenkins SCM credentials ID for Git repo checkout"
  type        = string
  default     = "github-token"
}

variable "jenkinsfile_enabled" {
  description = "Whether to generate Jenkinsfile"
  type        = bool
  default     = true
}

variable "jenkins_github_credentials_id" {
  description = "Jenkins credentials ID for GitHub token"
  type        = string
  default     = "github-token"
}

variable "jenkins_gitlab_credentials_id" {
  description = "Jenkins credentials ID for GitLab token"
  type        = string
  default     = "gitlab-token"
}

variable "sync_script_enabled" {
  description = "Whether to generate sync_repos.py"
  type        = bool
  default     = true
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
