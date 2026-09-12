# One CMK, used for EKS Kubernetes-secrets envelope encryption. Also
# referenced later (Chapter 9) as the encryption key backing Secrets
# Manager entries, so app secrets and cluster secrets share one auditable
# key with one rotation policy.

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "main" {
  description             = "${var.name_prefix} - EKS secrets + Secrets Manager envelope key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAccountAccess"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-kms"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.name_prefix}"
  target_key_id = aws_kms_key.main.key_id
}
