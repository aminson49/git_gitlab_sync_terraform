# Safe Terraform apply script that excludes S3 bucket and state resources
# This prevents accidental destruction of the state backend

Write-Host "Running Terraform apply (excluding state backend resources)..." -ForegroundColor Green

# Apply only the sync modules, excluding state backend
terraform apply `
    -target="module.github_to_gitlab_sync" `
    -target="module.gitlab_to_github_sync" `
    -refresh=false

Write-Host "`nApply complete!" -ForegroundColor Green
Write-Host "Note: State backend resources (S3, DynamoDB) were excluded from this operation." -ForegroundColor Yellow
