variable "name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "Output from infra/bootstrap — the GitHub OIDC provider ARN."
}

variable "github_org" {
  type        = string
  description = "Your GitHub username or org, e.g. akshay-mishra"
}

variable "github_repo" {
  type        = string
  description = "Repo name only, no org prefix, e.g. devsecops-pipeline-demo"
}

variable "ecr_repo_prefix" {
  type        = string
  description = "Matches the actual ECR repo naming in environments/stage/main.tf (var.project_name there) - deliberately NOT the same as name_prefix, which includes -stage and doesn't match the real repo names."
}