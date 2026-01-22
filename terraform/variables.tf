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

variable "jenkins_scm_credentials_enabled" {
  description = "Whether to create Jenkins SCM credentials for Git checkout"
  type        = bool
  default     = true
}

variable "jenkins_scm_username" {
  description = "Username for Jenkins SCM credentials"
  type        = string
}

variable "jenkins_scm_token" {
  description = "Token/password for Jenkins SCM credentials"
  type        = string
  sensitive   = true
}

variable "jenkins_scm_credentials_description" {
  description = "Description for Jenkins SCM credentials"
  type        = string
  default     = "GitHub SCM token"
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

variable "jenkins_token_credentials_enabled" {
  description = "Whether to create Jenkins token credentials"
  type        = bool
  default     = true
}

variable "jenkins_github_token_description" {
  description = "Description for GitHub token credential"
  type        = string
  default     = "GitHub API token"
}

variable "jenkins_gitlab_token_description" {
  description = "Description for GitLab token credential"
  type        = string
  default     = "GitLab API token"
}

variable "sync_script_enabled" {
  description = "Whether to generate sync_repos.py"
  type        = bool
  default     = true
}

variable "push_generated_files_enabled" {
  description = "Whether to commit and push generated files"
  type        = bool
  default     = false
}

variable "push_remote_name" {
  description = "Git remote name used for pushing generated files"
  type        = string
  default     = "origin"
}

variable "push_branch" {
  description = "Git branch to push generated files to"
  type        = string
  default     = "main"
}

variable "push_commit_message" {
  description = "Commit message for generated files push"
  type        = string
  default     = "Update generated sync files"
}

variable "push_auth_enabled" {
  description = "Whether to use token auth for git push"
  type        = bool
  default     = false
}

variable "push_auth_username" {
  description = "Username for token-based git push"
  type        = string
  default     = "x-access-token"
}

variable "push_auth_token" {
  description = "Token for git push authentication"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for state storage"
  type        = string
  default     = "us-east-1"
}

variable "state_bootstrap_enabled" {
  description = "Create S3 + DynamoDB for Terraform state"
  type        = bool
  default     = true
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "state_lock_table_name" {
  description = "DynamoDB table name for state locking"
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
