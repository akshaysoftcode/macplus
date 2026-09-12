variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "Used only for the kubernetes.io/cluster/<name> subnet discovery tag EKS/ALB controller need."
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
