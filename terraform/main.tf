module "github_to_gitlab_sync" {
  source = "./modules/github_to_gitlab"
  
  github_repo_name    = var.github_to_gitlab.github_repo_name
  github_repo_full    = var.github_to_gitlab.github_repo_full
  gitlab_project_path = var.github_to_gitlab.gitlab_project_path
  github_token        = var.github_token
  jenkins_webhook_url = var.jenkins_webhook_url
}

module "gitlab_to_github_sync" {
  source = "./modules/gitlab_to_github"
  
  github_repo_name    = var.gitlab_to_github.github_repo_name
  github_repo_full    = var.gitlab_to_github.github_repo_full
  gitlab_project_path = var.gitlab_to_github.gitlab_project_path
  github_token        = var.github_token
}
