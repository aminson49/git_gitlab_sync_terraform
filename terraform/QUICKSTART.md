# Quick Start Guide

This guide will help you set up Terraform to automate your GitHub-GitLab sync configuration.

## Step 1: Install Terraform

If you don't have Terraform installed:

**Windows:**
```powershell
# Using Chocolatey
choco install terraform

# Or download from https://www.terraform.io/downloads
```

**Linux/Mac:**
```bash
# Using package manager or download from https://www.terraform.io/downloads
```

## Step 2: Get Your Tokens

### GitHub Token
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name it "terraform-sync"
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `admin:repo_hook` (Full control of repository hooks)
5. Generate and copy the token (starts with `ghp_`)

### GitLab Token
1. Go to https://gitlab.com/-/user_settings/personal_access_tokens
2. Name it "terraform-sync"
3. Select scopes:
   - ✅ `api`
   - ✅ `write_repository`
   - ✅ `read_repository`
4. Create and copy the token (starts with `glpat-`)

## Step 3: Configure Terraform

1. **Navigate to the terraform directory:**
   ```bash
   cd terraform
   ```

2. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit `terraform.tfvars` with your values:**
   ```hcl
   github_token = "ghp_your_actual_token_here"
   github_owner = "your_github_username"
   
   gitlab_token = "glpat-your_actual_token_here"
   
   # Jenkins webhook URL (required for GitHub to GitLab sync)
   jenkins_webhook_url = "https://your-jenkins-domain.com/github-webhook/"
   
   github_to_gitlab = {
     github_repo_full      = "your_username/git_gitlab_sync"
     gitlab_project_path   = "your_group/gitlab_github_sync"
   }
   
   gitlab_to_github = {
     github_repo_full      = "your_username/gitlab_github_sync"
     gitlab_project_path   = "your_group/gitlab_github_sync"
   }
   ```

## Step 4: Initialize and Apply

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```
   This downloads the required providers (GitHub and GitLab).

2. **Review what will be created:**
   ```bash
   terraform plan
   ```
   Review the output to see what resources will be created.

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```
   Type `yes` when prompted to confirm.

## Step 5: Verify

### Check GitHub
1. Go to your GitHub repository
2. Settings → Webhooks
3. Verify the Jenkins webhook exists and is active
4. Check the webhook URL matches your Jenkins instance

### Check GitLab
1. Go to your GitLab project
2. Settings → CI/CD → Variables
3. Verify these variables exist:
   - `GITHUB_TOKEN` (masked)
   - `GITHUB_REPO_URL`
   - `GITLAB_REPO`

4. Check CI/CD → Pipelines
5. Verify the pipeline configuration is active

## Common Issues

### "Repository not found"
- Verify repository paths are correct (format: `owner/repo` for GitHub, `group/project` for GitLab)
- Ensure tokens have access to both repositories

### "Token invalid"
- Check token hasn't expired
- Verify token has all required scopes
- Make sure you copied the full token (not truncated)

### "Permission denied"
- GitHub token needs `admin:repo_hook` scope for webhooks
- GitLab token needs `api` scope for variables

### "Variable already exists"
- If variables already exist, Terraform will update them
- This is normal and expected behavior

## Next Steps

After Terraform setup is complete:

1. **For GitHub to GitLab sync:**
   - The GitHub Actions workflow is ready (manual trigger)
   - If using Jenkins, configure the webhook URL in `terraform.tfvars`
   - Push to GitHub and manually trigger the workflow, or set up Jenkins

2. **For GitLab to GitHub sync:**
   - The GitLab CI pipeline runs automatically on push
   - Push to GitLab and check the pipeline status
   - Verify sync is working by checking GitHub

3. **Monitor sync:**
   - Check GitHub Actions logs
   - Check GitLab CI/CD pipeline logs
   - Verify branches are syncing correctly

## Updating Configuration

To update your configuration:

1. Edit `terraform.tfvars`
2. Run `terraform plan` to see changes
3. Run `terraform apply` to apply changes

## Removing Configuration

To remove all Terraform-managed resources:

```bash
terraform destroy
```

**Warning:** This will delete all secrets, webhooks, and CI/CD variables created by Terraform.
