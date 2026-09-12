# Fill in bucket/dynamodb_table with the actual output values from
# `terraform output` in infra/bootstrap after you've run that once.
# Terraform backend blocks cannot use variables, so this has to be literal.

terraform {
  backend "s3" {
    bucket         = "REPLACE-WITH-YOUR-STATE-BUCKET-NAME"
    key            = "stage/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "devsecops-tf-lock"
    encrypt        = true
  }
}
