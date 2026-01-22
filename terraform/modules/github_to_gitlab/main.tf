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
  template = templatefile("${path.module}/templates/jenkins-job.xml.tpl", {
    github_repo_full            = var.github_repo_full
    jenkins_job_branch          = var.jenkins_job_branch
    jenkins_scm_credentials_id  = var.jenkins_scm_credentials_id
  })
}

resource "null_resource" "jenkins_scm_credentials" {
  count = var.jenkins_job_enabled && var.jenkins_scm_credentials_enabled ? 1 : 0

  triggers = {
    jenkins_url = var.jenkins_url
    jenkins_user = var.jenkins_username
    cred_id = var.jenkins_scm_credentials_id
    cred_user = var.jenkins_scm_username
    cred_desc = var.jenkins_scm_credentials_description
    cred_token_hash = sha256(var.jenkins_scm_token)
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    environment = {
      JENKINS_URL = var.jenkins_url
      JENKINS_USER = var.jenkins_username
      JENKINS_TOKEN = var.jenkins_api_token
      JENKINS_CRED_ID = var.jenkins_scm_credentials_id
      JENKINS_CRED_USER = var.jenkins_scm_username
      JENKINS_CRED_TOKEN = var.jenkins_scm_token
      JENKINS_CRED_DESC = var.jenkins_scm_credentials_description
    }
    command = <<-EOT
      $baseUrl = $env:JENKINS_URL.TrimEnd('/')
      $user = $env:JENKINS_USER
      $token = $env:JENKINS_TOKEN
      $credId = $env:JENKINS_CRED_ID
      $scmUser = $env:JENKINS_CRED_USER
      $scmToken = $env:JENKINS_CRED_TOKEN
      $desc = $env:JENKINS_CRED_DESC

      $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$user`:$token"))
      $headers = @{ Authorization = "Basic $basic" }

      try {
        $crumbResp = Invoke-RestMethod -Uri "$baseUrl/crumbIssuer/api/json" -Headers $headers -Method Get -ErrorAction Stop
        if ($crumbResp.crumbRequestField -and $crumbResp.crumb) {
          $headers[$crumbResp.crumbRequestField] = $crumbResp.crumb
        }
      } catch {
      }

      $credExists = $false
      try {
        Invoke-RestMethod -Uri "$baseUrl/credentials/store/system/domain/_/credential/$credId/api/json" -Headers $headers -Method Get -ErrorAction Stop | Out-Null
        $credExists = $true
      } catch {
        $credExists = $false
      }

      if (-not $credExists) {
        $payload = @{
          "" = "0"
          credentials = @{
            scope = "GLOBAL"
            id = $credId
            username = $scmUser
            password = $scmToken
            description = $desc
            '$class' = 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
          }
        } | ConvertTo-Json -Depth 5

        $form = @{
          json = $payload
        }

        Invoke-RestMethod -Uri "$baseUrl/credentials/store/system/domain/_/createCredentials" `
          -Headers $headers -Method Post -ContentType "application/x-www-form-urlencoded" -Body $form | Out-Null
      }
    EOT
  }
}

resource "null_resource" "jenkins_token_credentials" {
  count = var.jenkins_job_enabled && var.jenkins_token_credentials_enabled ? 1 : 0

  triggers = {
    jenkins_url = var.jenkins_url
    jenkins_user = var.jenkins_username
    github_cred_id = var.jenkins_github_credentials_id
    gitlab_cred_id = var.jenkins_gitlab_credentials_id
    github_token_hash = sha256(var.github_token)
    gitlab_token_hash = sha256(var.gitlab_token)
    github_desc = var.jenkins_github_token_description
    gitlab_desc = var.jenkins_gitlab_token_description
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    environment = {
      JENKINS_URL = var.jenkins_url
      JENKINS_USER = var.jenkins_username
      JENKINS_TOKEN = var.jenkins_api_token
      GITHUB_CRED_ID = var.jenkins_github_credentials_id
      GITLAB_CRED_ID = var.jenkins_gitlab_credentials_id
      GITHUB_TOKEN = var.github_token
      GITLAB_TOKEN = var.gitlab_token
      GITHUB_DESC = var.jenkins_github_token_description
      GITLAB_DESC = var.jenkins_gitlab_token_description
    }
    command = <<-EOT
      $baseUrl = $env:JENKINS_URL.TrimEnd('/')
      $user = $env:JENKINS_USER
      $token = $env:JENKINS_TOKEN

      $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$user`:$token"))
      $headers = @{ Authorization = "Basic $basic" }

      try {
        $crumbResp = Invoke-RestMethod -Uri "$baseUrl/crumbIssuer/api/json" -Headers $headers -Method Get -ErrorAction Stop
        if ($crumbResp.crumbRequestField -and $crumbResp.crumb) {
          $headers[$crumbResp.crumbRequestField] = $crumbResp.crumb
        }
      } catch {
      }

      function Ensure-SecretCredential($credId, $secret, $desc) {
        $credExists = $false
        try {
          Invoke-RestMethod -Uri "$baseUrl/credentials/store/system/domain/_/credential/$credId/api/json" -Headers $headers -Method Get -ErrorAction Stop | Out-Null
          $credExists = $true
        } catch {
          $credExists = $false
        }

        if (-not $credExists) {
          $payload = @{
            "" = "0"
            credentials = @{
              scope = "GLOBAL"
              id = $credId
              secret = $secret
              description = $desc
              '$class' = 'org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl'
            }
          } | ConvertTo-Json -Depth 5

          $form = @{ json = $payload }

          Invoke-RestMethod -Uri "$baseUrl/credentials/store/system/domain/_/createCredentials" `
            -Headers $headers -Method Post -ContentType "application/x-www-form-urlencoded" -Body $form | Out-Null
        }
      }

      Ensure-SecretCredential $env:GITHUB_CRED_ID $env:GITHUB_TOKEN $env:GITHUB_DESC
      Ensure-SecretCredential $env:GITLAB_CRED_ID $env:GITLAB_TOKEN $env:GITLAB_DESC
    EOT
  }
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

resource "null_resource" "push_generated_files" {
  count = var.push_generated_files_enabled ? 1 : 0

  triggers = {
    jenkinsfile_hash = fileexists("${path.root}/../Jenkinsfile") ? filesha256("${path.root}/../Jenkinsfile") : ""
    sync_script_hash = fileexists("${path.root}/../sync_repos.py") ? filesha256("${path.root}/../sync_repos.py") : ""
    gitlab_ci_hash   = fileexists("${path.root}/../.gitlab-ci.yml") ? filesha256("${path.root}/../.gitlab-ci.yml") : ""
    push_remote      = var.push_remote_name
    push_branch      = var.push_branch
    push_message     = var.push_commit_message
    push_auth_enabled = tostring(var.push_auth_enabled)
    push_auth_username = var.push_auth_username
    push_auth_token_hash = var.push_auth_enabled ? sha256(var.push_auth_token) : ""
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    working_dir = "${path.root}/.."
    environment = {
      PUSH_REMOTE = var.push_remote_name
      PUSH_BRANCH = var.push_branch
      PUSH_MESSAGE = var.push_commit_message
      PUSH_AUTH_ENABLED = tostring(var.push_auth_enabled)
      PUSH_AUTH_USERNAME = var.push_auth_username
      PUSH_AUTH_TOKEN = var.push_auth_token
    }
    command = <<-EOT
      $files = @("Jenkinsfile", "sync_repos.py", ".gitlab-ci.yml")
      foreach ($file in $files) {
        if (Test-Path $file) {
          git add $file | Out-Null
        }
      }

      $status = git status --porcelain
      if (-not $status) {
        exit 0
      }

      $remote = $env:PUSH_REMOTE
      $branch = $env:PUSH_BRANCH
      $authEnabled = $env:PUSH_AUTH_ENABLED -eq "true"
      $origUrl = ""

      if ($authEnabled) {
        $origUrl = git remote get-url $remote
        $tokenUser = $env:PUSH_AUTH_USERNAME
        $token = $env:PUSH_AUTH_TOKEN

        if (-not $token) {
          Write-Error "PUSH_AUTH_TOKEN is empty"
          exit 1
        }

        $authUrl = $origUrl -replace "^https://", "https://$tokenUser`:$token@"
        if ($authUrl -eq $origUrl) {
          Write-Error "Remote URL must be https for token auth"
          exit 1
        }

        git remote set-url $remote $authUrl | Out-Null
      }

      git commit -m "$env:PUSH_MESSAGE" | Out-Null
      git push $remote $branch | Out-Null

      if ($authEnabled -and $origUrl) {
        git remote set-url $remote $origUrl | Out-Null
      }
    EOT
  }
}
