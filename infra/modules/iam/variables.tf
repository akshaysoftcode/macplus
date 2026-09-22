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

variable "github_owner_id" {
  type        = string
  description = "Numeric GitHub owner/org ID - needed for the immutable subject claim format. Get it from a decoded OIDC token's 'repository_owner_id' field, or GET /users/{owner} via the GitHub API ('id' field)."
}

variable "github_repo_id" {
  type        = string
  description = "Numeric GitHub repository ID - needed for the immutable subject claim format. Get it from a decoded OIDC token's 'repository_id' field, or GET /repos/{owner}/{repo} via the GitHub API ('id' field)."
}

variable "ecr_repo_prefix" {
  type        = string
  description = "Matches the actual ECR repo naming in environments/stage/main.tf (var.project_name there) - deliberately NOT the same as name_prefix, which includes -stage and doesn't match the real repo names."
} 