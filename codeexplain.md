# Terraform Code Explanation

This document walks through the Terraform code that sets up bidirectional sync between GitHub and GitLab. I'll explain what each file does and why it's structured this way.

## Overview

The setup works in two directions:
- **GitHub → GitLab**: When you push to GitHub, a webhook triggers Jenkins, which runs a sync script
- **GitLab → GitHub**: When you push to GitLab, GitLab CI runs automatically and syncs back to GitHub

Let's break down each file:

---

## versions.tf

This file tells Terraform which version to use and which providers we need.

```terraform
terraform {
  required_version = ">= 1.0"
```
We're requiring Terraform version 1.0 or higher. This ensures we have all the features we need.

```terraform
  required_providers {
```
Here we list all the external services we'll be talking to. Think of providers as plugins that let Terraform talk to different services.

```terraform
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
```
The GitHub provider lets us create webhooks and manage repository settings. Version ~> 5.0 means "5.0 or higher, but less than 6.0" - so we get bug fixes but avoid breaking changes.

```terraform
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 16.0"
    }
```
Similar for GitLab - we can set up CI/CD variables and project settings.

```terraform
    jenkins = {
      source  = "taiidani/jenkins"
      version = "~> 0.9"
    }
```
The Jenkins provider creates jobs and manages credentials. This is a community provider (not official), but it works well.

```terraform
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
```
The null provider is interesting - it doesn't create any actual resources. We use it to run scripts (like PowerShell commands) that set up Jenkins credentials via API calls, since the Jenkins provider doesn't handle credentials well.

```terraform
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
```
AWS provider for storing Terraform state in S3 and using DynamoDB for locking (prevents two people from running terraform apply at the same time).

---

## providers.tf

This file configures how Terraform connects to each service.

```terraform
provider "github" {
  token = var.github_token
  owner = var.github_owner
}
```
We're authenticating to GitHub using a personal access token. The owner is your GitHub username or organization name. Terraform will use this to make API calls.

```terraform
provider "gitlab" {
  token    = var.gitlab_token
  base_url = var.gitlab_base_url
}
```
Same idea for GitLab. The base_url defaults to gitlab.com, but you could point this at a self-hosted GitLab instance.

```terraform
provider "jenkins" {
  server_url = var.jenkins_url
  username   = var.jenkins_username
  password   = var.jenkins_api_token
}
```
Jenkins uses basic auth - username and API token. The server_url is where your Jenkins instance lives (like http://3.238.87.62:8080).

```terraform
provider "aws" {
  region = var.aws_region
}
```
AWS provider just needs to know which region to use. Defaults to us-east-1.

---

## variables.tf

This file defines all the inputs you need to provide. Think of it as the "settings" for your infrastructure.

```terraform
variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}
```
The `sensitive = true` flag means Terraform won't print this value in logs or outputs. Important for security.

```terraform
variable "jenkins_webhook_url" {
  description = "Jenkins webhook endpoint URL"
  type        = string
}
```
This is the full URL where GitHub should send webhook events. Usually something like `http://your-jenkins:8080/github-webhook/`.

```terraform
variable "jenkins_job_enabled" {
  description = "Whether to create a Jenkins job for GitHub->GitLab sync"
  type        = bool
  default     = false
}
```
This is a toggle. If you set it to `false`, Terraform won't create the Jenkins job. Useful if you want to set up the webhook first, then create the job later.

```terraform
variable "github_to_gitlab" {
  description = "GitHub to GitLab sync configuration"
  type = object({
    github_repo_name    = string
    github_repo_full    = string
    gitlab_project_path = string
  })
}
```
This is a complex variable - it's an object with three fields. We use this to group related settings together. So in your tfvars file, you'd write:

```
github_to_gitlab = {
  github_repo_name    = "my-repo"
  github_repo_full    = "username/my-repo"
  gitlab_project_path = "group/project"
}
```

---

## main.tf

This is where the actual work happens. We're calling two modules - think of modules as reusable chunks of Terraform code.

```terraform
module "github_to_gitlab_sync" {
  source = "./modules/github_to_gitlab"
```
We're using a local module (in the same repo) at `./modules/github_to_gitlab`. This module handles everything for the GitHub → GitLab direction.

```terraform
  github_repo_name    = var.github_to_gitlab.github_repo_name
  github_repo_full    = var.github_to_gitlab.github_repo_full
  gitlab_project_path = var.github_to_gitlab.gitlab_project_path
```
We're passing values from our variables into the module. The module needs to know which repos to sync.

```terraform
  jenkins_webhook_url = var.jenkins_webhook_url
  jenkins_url = var.jenkins_url
  jenkins_username = var.jenkins_username
  jenkins_api_token = var.jenkins_api_token
```
All the Jenkins connection details get passed through. The module will use these to create the webhook and set up the job.

```terraform
module "gitlab_to_github_sync" {
  source = "./modules/gitlab_to_github"
  
  github_repo_name    = var.gitlab_to_github.github_repo_name
  github_repo_full    = var.gitlab_to_github.github_repo_full
  gitlab_project_path = var.gitlab_to_github.gitlab_project_path
  github_token        = var.github_token
}
```
The second module handles GitLab → GitHub. It's simpler because GitLab CI handles the sync directly - we just need to set up CI/CD variables.

---

## state_backend.tf

This file creates the infrastructure that Terraform uses to store its own state. It's a bit meta - Terraform is creating resources that Terraform will use.

```terraform
resource "aws_s3_bucket" "tf_state" {
  count  = var.state_bootstrap_enabled ? 1 : 0
  bucket = var.state_bucket_name
```
The `count` line is a conditional. If `state_bootstrap_enabled` is true, it creates 1 bucket. If false, it creates 0 (doesn't create it at all). This lets you opt out if you already have a state bucket.

```terraform
  lifecycle {
    prevent_destroy = true
  }
```
This is a safety feature. Even if you run `terraform destroy`, it won't delete this bucket. This prevents you from accidentally losing your Terraform state (which would be catastrophic - you'd lose track of all your infrastructure).

```terraform
resource "aws_s3_bucket_versioning" "tf_state" {
  count  = var.state_bootstrap_enabled ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id
```
This enables versioning on the S3 bucket. If something goes wrong, you can roll back to a previous version of your state file.

```terraform
  versioning_configuration {
    status = "Enabled"
  }
```
Just turning on versioning. AWS keeps old versions of files automatically.

```terraform
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  count  = var.state_bootstrap_enabled ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```
Encrypting the state file at rest. The state file contains sensitive info (tokens, etc.), so encryption is important. AES256 is AWS's standard encryption.

```terraform
resource "aws_dynamodb_table" "tf_lock" {
  count        = var.state_bootstrap_enabled ? 1 : 0
  name         = var.state_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
```
DynamoDB table for state locking. When you run `terraform apply`, it writes a lock to this table. If someone else tries to run terraform at the same time, they'll see the lock and wait. Prevents conflicts.

```terraform
  hash_key     = "LockID"
```
The primary key for the table. Each lock has a unique LockID.

```terraform
  attribute {
    name = "LockID"
    type = "S"
  }
```
Defining the attribute. "S" means string type.

---

## outputs.tf

Outputs are values that Terraform prints after it runs. Useful for seeing what was created.

```terraform
output "github_to_gitlab_webhook_url" {
  value = module.github_to_gitlab_sync.webhook_url
}
```
After creating the webhook, we output the URL so you can verify it was set correctly.

```terraform
output "gitlab_to_github_ci_variables" {
  value = module.gitlab_to_github_sync.gitlab_ci_variables
}
```
Shows what CI/CD variables were set in GitLab. The value shows as "configured" for sensitive ones (doesn't print the actual token).

---

## modules/github_to_gitlab/main.tf

This module handles the GitHub → GitLab sync direction. Let's look at the key parts:

```terraform
data "github_repository" "repo" {
  full_name = var.github_repo_full
}
```
This is a data source - it doesn't create anything, just reads info about an existing GitHub repo. We use it to get the repo name.

```terraform
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
```
This creates a webhook in GitHub. When someone pushes to the repo, GitHub will send a POST request to the Jenkins URL. We only listen for "push" events (not pull requests, issues, etc.).

```terraform
resource "jenkins_job" "github_to_gitlab_sync" {
  count = var.jenkins_job_enabled ? 1 : 0

  name = var.jenkins_job_name
  template = templatefile("${path.module}/templates/jenkins-job.xml.tpl", {
    github_repo_full            = var.github_repo_full
    jenkins_job_branch          = var.jenkins_job_branch
    jenkins_scm_credentials_id  = var.jenkins_scm_credentials_id
  })
}
```
Creates a Jenkins pipeline job. The template is an XML file that defines the job configuration. We use `templatefile()` to inject variables into the template.

```terraform
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
```
This is a null_resource - it doesn't create a Terraform-managed resource. Instead, it runs a script. The `triggers` block tells Terraform when to re-run the script. If any of these values change, Terraform will destroy and recreate this resource (which re-runs the script).

We hash the token instead of storing it directly - that way if the token changes, Terraform knows to update, but we're not storing the plain token in state.

```terraform
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    environment = {
      JENKINS_URL = var.jenkins_url
      JENKINS_USER = var.jenkins_username
      JENKINS_TOKEN = var.jenkins_api_token
      ...
    }
    command = <<-EOT
      $baseUrl = $env:JENKINS_URL.TrimEnd('/')
      $user = $env:JENKINS_USER
      $token = $env:JENKINS_TOKEN
```
The provisioner runs a PowerShell script. We're using environment variables to pass sensitive data (tokens) to the script. The script will make API calls to Jenkins to create credentials.

```terraform
      $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$user`:$token"))
      $headers = @{ Authorization = "Basic $basic" }
```
Jenkins uses HTTP Basic Auth. We're encoding the username:password as base64 and putting it in the Authorization header.

```terraform
      try {
        $crumbResp = Invoke-RestMethod -Uri "$baseUrl/crumbIssuer/api/json" -Headers $headers -Method Get -ErrorAction Stop
        if ($crumbResp.crumbRequestField -and $crumbResp.crumb) {
          $headers[$crumbResp.crumbRequestField] = $crumbResp.crumb
        }
      } catch {
      }
```
Jenkins has CSRF protection. We need to get a "crumb" (token) and include it in subsequent requests. If CSRF is disabled, this will fail gracefully.

```terraform
      $credExists = $false
      try {
        Invoke-RestMethod -Uri "$baseUrl/credentials/store/system/domain/_/credential/$credId/api/json" -Headers $headers -Method Get -ErrorAction Stop | Out-Null
        $credExists = $true
      } catch {
        $credExists = $false
      }
```
Check if the credential already exists. If the API call succeeds, it exists. If it 404s, it doesn't exist.

```terraform
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
```
If it doesn't exist, create it. The payload is JSON that Jenkins expects. The `$class` field tells Jenkins what type of credential this is (username/password).

```terraform
        Invoke-RestMethod -Uri "$baseUrl/credentials/store/system/domain/_/createCredentials" `
          -Headers $headers -Method Post -ContentType "application/x-www-form-urlencoded" -Body $form | Out-Null
```
POST the credential to Jenkins. The endpoint is Jenkins's API for creating credentials.

The `jenkins_token_credentials` resource does the same thing but for GitHub and GitLab API tokens (instead of SCM credentials).

---

## modules/gitlab_to_github/main.tf

This module is simpler - it just sets up GitLab CI/CD variables.

```terraform
data "gitlab_project" "project" {
  path_with_namespace = var.gitlab_project_path
}
```
Look up the GitLab project. `path_with_namespace` is like "group/project".

```terraform
resource "gitlab_project_variable" "github_token" {
  project       = data.gitlab_project.project.id
  key           = "GITHUB_TOKEN"
  value         = var.github_token
  protected     = false
  masked        = true
  variable_type = "env_var"
}
```
Create a CI/CD variable in GitLab. `masked = true` means GitLab won't print it in job logs (security). `protected = false` means it's available to all branches, not just protected ones.

```terraform
resource "gitlab_project_variable" "github_repo_url" {
  project       = data.gitlab_project.project.id
  key           = "GITHUB_REPO_URL"
  value         = "https://github.com/${var.github_repo_full}.git"
  protected     = false
  masked        = false
  variable_type = "env_var"
}
```
The repo URL doesn't need to be masked (it's not sensitive), so `masked = false`.

```terraform
resource "local_file" "gitlab_ci_config" {
  filename = "${path.root}/../.gitlab-ci.yml"
  content = templatefile("${path.module}/templates/gitlab-ci.tpl", {
    github_repo_url = "https://github.com/${var.github_repo_full}.git"
  })
}
```
This creates a `.gitlab-ci.yml` file in the repo root. GitLab automatically runs CI/CD based on this file. The template contains the sync script that pushes changes to GitHub.

---

## How It All Works Together

1. **You run `terraform apply`** with your tfvars file
2. **Terraform creates:**
   - GitHub webhook pointing to Jenkins
   - Jenkins job that runs on webhook events
   - Jenkins credentials for accessing GitHub/GitLab
   - GitLab CI/CD variables
   - `.gitlab-ci.yml` file in your repo
3. **When you push to GitHub:**
   - GitHub sends webhook to Jenkins
   - Jenkins job runs, clones repo, runs sync script
   - Script pushes changes to GitLab
4. **When you push to GitLab:**
   - GitLab CI runs automatically (because of `.gitlab-ci.yml`)
   - CI job uses the variables we set up
   - Script pushes changes to GitHub

The beauty is that once it's set up, it just works. Both repos stay in sync automatically.

---

## Common Gotchas

- **State file location**: Make sure your S3 bucket exists before you start, or enable `state_bootstrap_enabled` to create it
- **Jenkins credentials**: The null_resource scripts run every time the triggers change. If you update the Jenkins URL, the credentials get recreated
- **Webhook URL**: Must be accessible from GitHub's servers. If Jenkins is behind a firewall, you'll need a public URL or webhook proxy
- **Token permissions**: GitHub token needs `repo` and `admin:repo_hook` scopes. GitLab token needs `api`, `read_repository`, `write_repository`

That's the gist of it! The code is modular so you can reuse the sync logic for different repo pairs.
