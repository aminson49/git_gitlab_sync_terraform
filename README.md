# GitHub ↔ GitLab Sync (Terraform)

Terraform configuration for bidirectional repository synchronization.

## Architecture

- GitHub → GitLab: Jenkins webhook triggers a sync job
- GitLab → GitHub: GitLab CI pipeline syncs on push

## What Terraform Creates

- GitHub webhook pointing to Jenkins
- GitLab CI variables and `.gitlab-ci.yml` for GitLab → GitHub sync
- Optional: Jenkins job, `Jenkinsfile`, and `sync_repos.py` in repo root

## Requirements

- Terraform >= 1.0
- GitHub token with `repo` and `admin:repo_hook`
- GitLab token with `api`, `read_repository`, `write_repository`
- Jenkins instance (optional) with API token if you want Jenkins job creation

## Setup

1. Copy the example file:
   ```
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Edit `terraform.tfvars` with your values.
3. Initialize and apply:
   ```
   terraform init
   terraform apply
   ```

## Repo Format

- GitHub: `owner/repo`
- GitLab: `group/project`

## Notes

- `terraform.tfvars` contains secrets; do not commit it.
- If `jenkinsfile_enabled = true`, Terraform regenerates `Jenkinsfile`.
- If `sync_script_enabled = true`, Terraform regenerates `sync_repos.py`.
