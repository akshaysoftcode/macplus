variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "devsecops-demo"
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "From `terraform output github_oidc_provider_arn` in infra/bootstrap."
}

variable "github_org" {
  type        = string
  description = "Your GitHub username, e.g. akshay-mishra"
}

variable "github_repo" {
  type        = string
  description = "Repo name only, e.g. devsecops-pipeline-demo"
}

variable "alb_controller_policy_arn" {
  type        = string
  default     = ""
  description = "ARN of the ALB controller IAM policy (see comment in main.tf for how to create it). Leave blank until Chapter 7/10 when the controller is actually deployed."
}
