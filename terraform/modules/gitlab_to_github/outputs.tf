output "gitlab_ci_variables" {
  value = {
    github_token    = "configured"
    github_repo_url = gitlab_project_variable.github_repo_url.value
    gitlab_repo     = gitlab_project_variable.gitlab_repo.value
  }
}
