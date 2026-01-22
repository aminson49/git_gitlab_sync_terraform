module "github_to_gitlab_sync" {
  source = "./modules/github_to_gitlab"
  
  github_repo_name    = var.github_to_gitlab.github_repo_name
  github_repo_full    = var.github_to_gitlab.github_repo_full
  gitlab_project_path = var.github_to_gitlab.gitlab_project_path
  github_token        = var.github_token
  gitlab_token        = var.gitlab_token
  jenkins_webhook_url = var.jenkins_webhook_url
  jenkins_url = var.jenkins_url
  jenkins_username = var.jenkins_username
  jenkins_api_token = var.jenkins_api_token
  jenkins_job_enabled = var.jenkins_job_enabled
  jenkins_job_name = var.jenkins_job_name
  jenkins_job_branch = var.jenkins_job_branch
  jenkins_scm_credentials_id = var.jenkins_scm_credentials_id
  jenkins_scm_credentials_enabled = var.jenkins_scm_credentials_enabled
  jenkins_scm_username = var.jenkins_scm_username
  jenkins_scm_token = var.jenkins_scm_token
  jenkins_scm_credentials_description = var.jenkins_scm_credentials_description
  jenkinsfile_enabled = var.jenkinsfile_enabled
  jenkins_github_credentials_id = var.jenkins_github_credentials_id
  jenkins_gitlab_credentials_id = var.jenkins_gitlab_credentials_id
  jenkins_token_credentials_enabled = var.jenkins_token_credentials_enabled
  jenkins_github_token_description = var.jenkins_github_token_description
  jenkins_gitlab_token_description = var.jenkins_gitlab_token_description
  sync_script_enabled = var.sync_script_enabled
  push_generated_files_enabled = var.push_generated_files_enabled
  push_remote_name = var.push_remote_name
  push_branch = var.push_branch
  push_commit_message = var.push_commit_message
  push_auth_enabled = var.push_auth_enabled
  push_auth_username = var.push_auth_username
  push_auth_token = var.push_auth_token
}

module "gitlab_to_github_sync" {
  source = "./modules/gitlab_to_github"
  
  github_repo_name    = var.gitlab_to_github.github_repo_name
  github_repo_full    = var.gitlab_to_github.github_repo_full
  gitlab_project_path = var.gitlab_to_github.gitlab_project_path
  github_token        = var.github_token
}
