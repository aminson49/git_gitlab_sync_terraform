output "github_to_gitlab_webhook_url" {
  value = module.github_to_gitlab_sync.webhook_url
}

output "github_to_gitlab_webhook_id" {
  value = module.github_to_gitlab_sync.webhook_id
}

output "gitlab_to_github_ci_variables" {
  value = module.gitlab_to_github_sync.gitlab_ci_variables
}
