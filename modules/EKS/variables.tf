variable "kubernetes_version" {
  default = 1.18
  description = "kubernetes version"
}

variable "vpc_id" {
}

variable "private_subnet_id_for_eks" {
  type = list(string)
}