provider "github" {
  token = var.github_token
  owner = var.github_owner
}

provider "gitlab" {
  token    = var.gitlab_token
  base_url = var.gitlab_base_url
}

provider "jenkins" {
  server_url = var.jenkins_url
  username   = var.jenkins_username
  api_token  = var.jenkins_api_token
}
