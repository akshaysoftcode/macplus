output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
  description = "Put this ARN into your GitHub Actions workflow's role-to-assume field."
}

output "ecr_api_repo_url" {
  value = aws_ecr_repository.api.repository_url
}

output "ecr_frontend_repo_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}
