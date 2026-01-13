output "webhook_url" {
  value = var.jenkins_webhook_url
}

output "webhook_id" {
  value = github_repository_webhook.jenkins.id
}
