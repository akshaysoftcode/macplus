terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project_name}-stage"
}

module "vpc" {
  source       = "../../modules/vpc"
  name_prefix  = local.name_prefix
  cluster_name = "${local.name_prefix}-eks"
}

module "kms" {
  source      = "../../modules/kms"
  name_prefix = local.name_prefix
}

module "iam" {
  source                   = "../../modules/iam"
  name_prefix               = local.name_prefix
  aws_region                = var.aws_region
  cluster_name               = "${local.name_prefix}-eks"
  github_oidc_provider_arn  = var.github_oidc_provider_arn
  github_org                = var.github_org
  github_repo                = var.github_repo
}

module "eks" {
  source              = "../../modules/eks"
  cluster_name        = "${local.name_prefix}-eks"
  k8s_version         = var.k8s_version  
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_role_arn       = module.iam.eks_node_role_arn
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  kms_key_arn         = module.kms.key_arn
  desired_size        = 2
  instance_types      = ["t3.small"]
}

# --- ALB controller IRSA role ---
# Lives here (not in the iam module) because it needs module.eks's OWN
# OIDC provider, which doesn't exist until the cluster is created —
# putting it inside modules/iam would make iam depend on eks and eks
# depend on iam at the same time. This is the actual ordering AWS's
# docs use too.
data "aws_iam_policy_document" "alb_controller_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${local.name_prefix}-alb-controller-irsa"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_trust.json
}

# AWS publishes the exact policy document for this controller; fetch it
# at deploy time rather than hand-copying a stale JSON blob:
#   curl -o alb-controller-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
# then: aws iam create-policy --policy-name ALBControllerPolicy --policy-document file://alb-controller-policy.json
# and attach its ARN below via var.alb_controller_policy_arn once created.
resource "aws_iam_role_policy_attachment" "alb_controller" {
  count      = var.alb_controller_policy_arn == "" ? 0 : 1
  role       = aws_iam_role.alb_controller.name
  policy_arn = var.alb_controller_policy_arn
}

# --- ECR repos ---
resource "aws_ecr_repository" "api" {
  name                 = "${var.project_name}-app-api"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = module.kms.key_arn
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-app-frontend"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = module.kms.key_arn
  }
}
