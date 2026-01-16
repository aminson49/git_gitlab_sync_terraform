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

resource "jenkins_job" "github_to_gitlab_sync" {
  count = var.jenkins_job_enabled ? 1 : 0

  name = var.jenkins_job_name
  xml = templatefile("${path.module}/templates/jenkins-job.xml.tpl", {
    github_repo_full            = var.github_repo_full
    jenkins_job_branch          = var.jenkins_job_branch
    jenkins_scm_credentials_id  = var.jenkins_scm_credentials_id
  })
}

resource "local_file" "jenkinsfile" {
  count    = var.jenkinsfile_enabled ? 1 : 0
  filename = "${path.root}/../Jenkinsfile"
  content = templatefile("${path.module}/templates/jenkinsfile.tpl", {
    github_repo_full               = var.github_repo_full
    gitlab_project_path            = var.gitlab_project_path
    jenkins_github_credentials_id  = var.jenkins_github_credentials_id
    jenkins_gitlab_credentials_id  = var.jenkins_gitlab_credentials_id
  })
}

resource "local_file" "sync_script" {
  count    = var.sync_script_enabled ? 1 : 0
  filename = "${path.root}/../sync_repos.py"
  content  = file("${path.module}/templates/sync_repos.py.tpl")
}
