variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Must be globally unique across all of AWS. Suggest: <yourname>-devsecops-tfstate"
}

variable "lock_table_name" {
  type    = string
  default = "devsecops-tf-lock"
}
