# --- BOOTSTRAP: run this ONCE, manually, before anything else ---
#
# This config intentionally uses LOCAL state, not remote state. Reason:
# it's the thing that CREATES the S3 bucket + DynamoDB table that the rest
# of the infra uses as its remote backend — it can't depend on a backend
# it hasn't created yet. Run this by hand, once, from your machine:
#
#   cd infra/bootstrap
#   terraform init
#   terraform apply
#
# terraform.tfstateaws --version will be created locally after apply — add it to
# .gitignore (already done at repo root) and do NOT commit it; it will
# contain resource IDs but no secrets. If you ever need to change this
# bootstrap config again, that local state file is how Terraform knows
# what already exists.

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Remote state backend: S3 bucket ---
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name

  # Prevents `terraform destroy` from ever silently deleting your state
  # history along with everything else.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Remote state lock table ---
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# --- GitHub OIDC provider ---
# This lets GitHub Actions assume AWS IAM roles via short-lived tokens —
# no long-lived AWS access keys ever stored as a GitHub secret.
# Thumbprint below is GitHub's current OIDC root CA thumbprint; AWS has
# also started accepting a fixed placeholder here on newer provider
# versions since it verifies via TLS, but pinning it explicitly is still
# the documented approach.
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]
}

output "state_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}

output "lock_table" {
  value = aws_dynamodb_table.tf_lock.name
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
