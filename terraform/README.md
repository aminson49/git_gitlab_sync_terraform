# Terraform: GitHub-GitLab Sync

Terraform configuration for bidirectional repository synchronization.

## Architecture

- **GitHub → GitLab**: Jenkins webhook triggers sync on push
- **GitLab → GitHub**: GitLab CI pipeline syncs automatically

## Setup

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Fill in your tokens and repository paths
3. Run `terraform init && terraform apply`

## Variables

Required variables:
- `github_token` - GitHub personal access token (repo, admin:repo_hook scopes)
- `gitlab_token` - GitLab personal access token (api, write_repository scopes)
- `github_owner` - GitHub username or organization
- `jenkins_webhook_url` - Jenkins webhook endpoint
- `github_to_gitlab` - Source and target repository configuration
- `gitlab_to_github` - Source and target repository configuration

## Repository Format

- GitHub: `owner/repo`
- GitLab: `group/project`

## Outputs

- `github_to_gitlab_webhook_url` - Configured webhook URL
- `github_to_gitlab_webhook_id` - Webhook ID
- `gitlab_to_github_ci_variables` - GitLab CI variables

## Notes

- Works with any repository paths you configure
- No hardcoded values - fully parameterized
- GitLab CI config is written to `.gitlab-ci.yml` in repo root
- Jenkins must be configured separately with pipeline and credentials
