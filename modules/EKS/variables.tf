variable "kubernetes_version" {
  default = 1.18
  description = "kubernetes version"
}

variable "vpc_id" {
}

variable "private_subnet_id_for_eks" {
  type = list(string)
}

locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "opsschool-sa"
}

locals {
  cluster_name = "opsschool-eks-${random_string.suffix.result}"
}
resource "random_string" "suffix" {
  length  = 8
  special = false
}