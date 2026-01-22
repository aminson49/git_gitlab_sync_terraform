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

variable "gitlab_token" {
  type      = string
  sensitive = true
}

variable "jenkins_webhook_url" {
  type = string
}

variable "jenkins_url" {
  type = string
}

variable "jenkins_username" {
  type = string
}

variable "jenkins_api_token" {
  type      = string
  sensitive = true
}

variable "jenkins_job_enabled" {
  type = bool
}

variable "jenkins_job_name" {
  type = string
}

variable "jenkins_job_branch" {
  type = string
}

variable "jenkins_scm_credentials_id" {
  type = string
}

variable "jenkins_scm_credentials_enabled" {
  type = bool
}

variable "jenkins_scm_username" {
  type = string
}

variable "jenkins_scm_token" {
  type      = string
  sensitive = true
}

variable "jenkins_scm_credentials_description" {
  type = string
}

variable "jenkinsfile_enabled" {
  type = bool
}

variable "jenkins_github_credentials_id" {
  type = string
}

variable "jenkins_gitlab_credentials_id" {
  type = string
}

variable "jenkins_token_credentials_enabled" {
  type = bool
}

variable "jenkins_github_token_description" {
  type = string
}

variable "jenkins_gitlab_token_description" {
  type = string
}

variable "sync_script_enabled" {
  type = bool
}

variable "push_generated_files_enabled" {
  type = bool
}

variable "push_remote_name" {
  type = string
}

variable "push_branch" {
  type = string
}

variable "push_commit_message" {
  type = string
}

variable "push_auth_enabled" {
  type = bool
}

variable "push_auth_username" {
  type = string
}

variable "push_auth_token" {
  type      = string
  sensitive = true
}
