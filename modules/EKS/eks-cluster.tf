module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "13.2.1"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnets         = var.private_subnet_id_for_eks

  enable_irsa = true
  
  tags = {
    Name = "OpsSchool-EKS"
  }

  vpc_id = var.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    }
    ,
    {
      name                          = "worker-group-3"
      instance_type                 = "t3.large"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    }
  ]

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
