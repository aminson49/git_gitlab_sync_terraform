data "github_repository" "repo" {
  full_name = var.github_repo_full
}

resource "github_repository_webhook" "jenkins" {
  repository = data.github_repository.repo.name
  active     = true

  configuration {
    url          = var.jenkins_webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  events = ["push"]
}
