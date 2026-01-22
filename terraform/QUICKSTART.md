# Quick start

Use this guide to get the sync running end to end.

## Install Terraform

- Windows:
  ```powershell
  choco install terraform
  ```
- Linux/Mac:
  ```bash
  # install with your package manager
  ```

## Create tokens

GitHub (classic PAT):
- https://github.com/settings/tokens
- Scopes: `repo`, `admin:repo_hook`

GitLab:
- https://gitlab.com/-/user_settings/personal_access_tokens
- Scopes: `api`, `read_repository`, `write_repository`

## Configure this repo

1. Go into the Terraform folder:
   ```bash
   cd terraform
   ```
2. Copy the example file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Edit `terraform.tfvars` and set your values.

## Apply

```bash
terraform init
terraform plan
terraform apply
```

## State storage (S3)

The Terraform state can be stored in S3 with DynamoDB locking.
This repo creates those resources once when `state_bootstrap_enabled = true`.

You still need to configure the backend for actual state storage. Once the
bucket/table exist, add a backend block and re-run `terraform init -migrate-state`.

## Verify

GitHub:
- Settings → Webhooks
- Webhook should point to your Jenkins URL

GitLab:
- Settings → CI/CD → Variables
- Pipelines should run on push

## Update or remove

- Update: edit `terraform.tfvars`, then `terraform apply`
- Remove: `terraform destroy`
