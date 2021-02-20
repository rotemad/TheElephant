module "VPC" {
  source = "./modules/VPC"
}

module "EC2-Jenkins" {
  source                         = "./modules/EC2-Jenkins"
  private_subnet_id              = module.VPC.private-subnets
  private_subnet_az              = module.VPC.private-subnet-az
  jenkins_private_security_group = module.VPC.private-sg-jenkins
  key_pair                       = module.VPC.aws-keypair
  consul_instance_profile        = module.EC2-Consul.consul-instance-profile
}

module "EC2-Consul" {
  source                        = "./modules/EC2-Consul"
  private_subnet_id             = module.VPC.private-subnets
  private_subnet_az             = module.VPC.private-subnet-az
  consul_private_security_group = module.VPC.private-sg-consul
  key_pair                      = module.VPC.aws-keypair
}

module "EKS" {
 source                        = "./modules/EKS"
 vpc_id                        = module.VPC.vpc-id
 private_subnet_id_for_eks     = module.VPC.private-subnets-for-eks
}

output "Bastion-Host" {
  value = module.VPC.bastion-servers
}
output "Jenkins-Master" {
  value = module.EC2-Jenkins.jenkins-master
}
output "Jenkins-Workers" {
  value = module.EC2-Jenkins.jenkins-workers
}
output "Consul-Servers" {
  value = module.EC2-Consul.consul-servers
}
output "EKS-Cluster-Name" {
  value = module.EKS.cluster_name
}