# Safe Terraform plan script that excludes S3 bucket and state resources
# This prevents the prevent_destroy error

Write-Host "Running Terraform plan (excluding state backend resources)..." -ForegroundColor Green

# Plan only the sync modules, excluding state backend
terraform plan `
    -target="module.github_to_gitlab_sync" `
    -target="module.gitlab_to_github_sync" `
    -refresh=false

Write-Host "`nPlan complete!" -ForegroundColor Green
Write-Host "Note: State backend resources (S3, DynamoDB) were excluded from this plan." -ForegroundColor Yellow
