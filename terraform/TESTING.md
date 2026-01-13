# Testing Guide

This guide walks you through testing the Terraform configuration and verifying the sync works.

## Step 1: Apply Terraform Configuration

1. **Review the plan:**
   ```bash
   cd terraform
   terraform plan
   ```

2. **Apply the configuration:**
   ```bash
   terraform apply
   ```
   Type `yes` when prompted.

3. **Verify outputs:**
   After apply completes, note the outputs:
   - `github_to_gitlab_webhook_url` - Your Jenkins webhook URL
   - `github_to_gitlab_webhook_id` - Webhook ID for reference
   - `gitlab_to_github_ci_variables` - GitLab CI variables that were set

## Step 2: Verify GitHub Webhook (GitHub → GitLab)

1. **Check webhook in GitHub:**
   - Go to your GitHub repository
   - Navigate to: Settings → Webhooks
   - You should see a webhook pointing to your Jenkins URL
   - Status should be "Active"
   - Events should include "push"

2. **Test webhook delivery:**
   - Make a small change in your GitHub repo (add a file or edit one)
   - Commit and push to GitHub
   - Go back to Settings → Webhooks
   - Click on the webhook
   - Check "Recent Deliveries" - you should see recent delivery attempts
   - Status should be "200 OK" if Jenkins is configured correctly

## Step 3: Verify GitLab CI Variables (GitLab → GitHub)

1. **Check GitLab CI variables:**
   - Go to your GitLab project
   - Navigate to: Settings → CI/CD → Variables
   - Verify these variables exist:
     - `GITHUB_TOKEN` (masked)
     - `GITHUB_REPO_URL`
     - `GITLAB_REPO`

2. **Check GitLab CI config:**
   - Go to your GitLab project root
   - Verify `.gitlab-ci.yml` file exists
   - Check the file content matches the template

## Step 4: Test GitLab → GitHub Sync

1. **Make a test change in GitLab:**
   ```bash
   # Clone your GitLab repo if you haven't
   git clone https://gitlab.com/your-group/your-project.git
   cd your-project
   
   # Create a test file
   echo "Test sync from GitLab" > test-sync.txt
   git add test-sync.txt
   git commit -m "Test: GitLab to GitHub sync"
   git push origin main
   ```

2. **Check GitLab CI pipeline:**
   - Go to GitLab project → CI/CD → Pipelines
   - You should see a new pipeline running
   - Click on it to see the job status
   - The `sync-to-github` job should run

3. **Verify sync to GitHub:**
   - Go to your GitHub repository
   - Check if `test-sync.txt` appears
   - Verify the commit message is there
   - Check the commit history

## Step 5: Test GitHub → GitLab Sync (Jenkins)

**Prerequisites:** Jenkins must be configured with:
- Pipeline job that runs `sync_repos.py code github-to-gitlab`
- Credentials for `GITHUB_TOKEN` and `GITLAB_TOKEN`
- Repository configured to match your GitHub repo

1. **Make a test change in GitHub:**
   ```bash
   # Clone your GitHub repo if you haven't
   git clone https://github.com/your-username/your-repo.git
   cd your-repo
   
   # Create a test file
   echo "Test sync from GitHub" > test-github-sync.txt
   git add test-github-sync.txt
   git commit -m "Test: GitHub to GitLab sync"
   git push origin main
   ```

2. **Check Jenkins:**
   - Go to your Jenkins instance
   - Check if the pipeline job was triggered
   - View the build logs
   - Verify the sync completed successfully

3. **Verify sync to GitLab:**
   - Go to your GitLab project
   - Check if `test-github-sync.txt` appears
   - Verify the commit is there

## Step 6: Test Sync Loop Prevention

The sync scripts use `[skip sync]` markers to prevent infinite loops.

1. **Test with [skip sync] marker:**
   ```bash
   # In GitLab repo
   echo "Test" > test.txt
   git add test.txt
   git commit -m "Test [skip sync]"
   git push origin main
   ```

2. **Verify:**
   - GitLab CI pipeline should run
   - Check the logs - it should say "Skipping sync - commit marked with [skip sync]"
   - The commit should NOT sync to GitHub

## Troubleshooting

### GitHub Webhook Not Triggering Jenkins

- **Check webhook URL:** Verify the URL in GitHub matches your Jenkins endpoint
- **Check Jenkins:** Ensure Jenkins is running and accessible
- **Check firewall:** Ensure Jenkins port is accessible from GitHub
- **Check webhook logs:** In GitHub, check "Recent Deliveries" for error messages

### GitLab CI Pipeline Failing

- **Check variables:** Verify all CI/CD variables are set correctly
- **Check token:** Ensure `GITHUB_TOKEN` has proper permissions
- **Check repo URL:** Verify `GITHUB_REPO_URL` is correct
- **Check pipeline logs:** Look at the job output for specific errors

### Sync Not Working

- **Check tokens:** Verify tokens have correct scopes
- **Check repository access:** Ensure tokens can access both repos
- **Check branch protection:** If branches are protected, tokens need permission
- **Check logs:** Review Jenkins/GitLab CI logs for specific errors

### Variables Not Appearing in GitLab

- **Check protected status:** If variables are "Protected", ensure branch is also protected
- **Check permissions:** Verify GitLab token has `api` scope
- **Refresh page:** Sometimes need to refresh GitLab UI

## Cleanup Test Files

After testing, you can remove test files:

```bash
# In GitHub repo
git rm test-sync.txt test-github-sync.txt
git commit -m "Remove test files"
git push origin main

# In GitLab repo  
git rm test-sync.txt test-github-sync.txt
git commit -m "Remove test files"
git push origin main
```

## Next Steps

Once testing is complete:
1. Monitor sync operations for a few days
2. Set up alerts/notifications for failed syncs
3. Document any custom configurations
4. Consider setting up monitoring dashboards
