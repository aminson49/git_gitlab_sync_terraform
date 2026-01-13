data "gitlab_project" "project" {
  path_with_namespace = var.gitlab_project_path
}

resource "gitlab_project_variable" "github_token" {
  project       = data.gitlab_project.project.id
  key           = "GITHUB_TOKEN"
  value         = var.github_token
  protected     = false
  masked        = true
  variable_type = "env_var"
}

resource "gitlab_project_variable" "github_repo_url" {
  project       = data.gitlab_project.project.id
  key           = "GITHUB_REPO_URL"
  value         = "https://github.com/${var.github_repo_full}.git"
  protected     = false
  masked        = false
  variable_type = "env_var"
}

resource "gitlab_project_variable" "gitlab_repo" {
  project       = data.gitlab_project.project.id
  key           = "GITLAB_REPO"
  value         = var.gitlab_project_path
  protected     = false
  masked        = false
  variable_type = "env_var"
}

resource "local_file" "gitlab_ci_config" {
  filename = "${path.root}/../.gitlab-ci.yml"
  content = templatefile("${path.module}/templates/gitlab-ci.tpl", {
    github_repo_url = "https://github.com/${var.github_repo_full}.git"
  })
}
