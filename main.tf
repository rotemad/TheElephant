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

module "EC2-Prometheus-Grafana" {
  source                            = "./modules/EC2-Prometheus-Grafana"
  private_subnet_id                 = module.VPC.private-subnets
  private_subnet_az                 = module.VPC.private-subnet-az
  prometheus_private_security_group = module.VPC.private-sg-prometheus
  key_pair                          = module.VPC.aws-keypair
  consul_instance_profile           = module.EC2-Consul.consul-instance-profile
}

module "EC2-ELK" {
  source                     = "./modules/EC2-ELK"
  private_subnet_id          = module.VPC.private-subnets
  private_subnet_az          = module.VPC.private-subnet-az
  elk_private_security_group = module.VPC.private-sg-elk
  key_pair                   = module.VPC.aws-keypair
  consul_instance_profile    = module.EC2-Consul.consul-instance-profile
}

module "EC2-MySQL" {
  source                       = "./modules/EC2-MySQL"
  private_subnet_id            = module.VPC.private-subnets
  private_subnet_az            = module.VPC.private-subnet-az
  mysql_private_security_group = module.VPC.private-sg-mysql
  key_pair                     = module.VPC.aws-keypair
  consul_instance_profile      = module.EC2-Consul.consul-instance-profile
}

module "Route53" {
  source                    = "./modules/Route53"
  vpc_id                    = module.VPC.vpc-id
  consul                    = module.EC2-Consul.consul-servers
  jenkins-master            = module.EC2-Jenkins.jenkins-master
  jenkins-worker            = module.EC2-Jenkins.jenkins-workers
  prom-grafana              = module.EC2-Prometheus-Grafana.prometheus-server
  elk                       = module.EC2-ELK.elk-server
  mysql                     = module.EC2-MySQL.mysql-server
}

module "EKS" {
  source                    = "./modules/EKS"
  vpc_id                    = module.VPC.vpc-id
  private_subnet_id_for_eks = module.VPC.private-subnets-for-eks
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
output "Prometheus-Grafana-Server" {
  value = module.EC2-Prometheus-Grafana.prometheus-server
}
 output "ELK-Server" {
  value = module.EC2-ELK.elk-server
}
output "MySQL-Server" {
  value = module.EC2-MySQL.mysql-server
}
output "ARN-For-K8S" {
  value = module.EC2-Consul.ec2-admin-arn
}