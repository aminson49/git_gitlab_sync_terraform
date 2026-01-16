module "github_to_gitlab_sync" {
  source = "./modules/github_to_gitlab"
  
  github_repo_name    = var.github_to_gitlab.github_repo_name
  github_repo_full    = var.github_to_gitlab.github_repo_full
  gitlab_project_path = var.github_to_gitlab.gitlab_project_path
  github_token        = var.github_token
  jenkins_webhook_url = var.jenkins_webhook_url
  jenkins_url = var.jenkins_url
  jenkins_username = var.jenkins_username
  jenkins_api_token = var.jenkins_api_token
  jenkins_job_enabled = var.jenkins_job_enabled
  jenkins_job_name = var.jenkins_job_name
  jenkins_job_branch = var.jenkins_job_branch
  jenkins_scm_credentials_id = var.jenkins_scm_credentials_id
  jenkinsfile_enabled = var.jenkinsfile_enabled
  jenkins_github_credentials_id = var.jenkins_github_credentials_id
  jenkins_gitlab_credentials_id = var.jenkins_gitlab_credentials_id
  sync_script_enabled = var.sync_script_enabled
}

module "gitlab_to_github_sync" {
  source = "./modules/gitlab_to_github"
  
  github_repo_name    = var.gitlab_to_github.github_repo_name
  github_repo_full    = var.gitlab_to_github.github_repo_full
  gitlab_project_path = var.gitlab_to_github.gitlab_project_path
  github_token        = var.github_token
}
