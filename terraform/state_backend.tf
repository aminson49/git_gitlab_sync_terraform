resource "aws_s3_bucket" "tf_state" {
  count  = var.state_bootstrap_enabled ? 1 : 0
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "terraform-state"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  count  = var.state_bootstrap_enabled ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  count  = var.state_bootstrap_enabled ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  count        = var.state_bootstrap_enabled ? 1 : 0
  name         = var.state_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "terraform-state-lock"
  }
}
