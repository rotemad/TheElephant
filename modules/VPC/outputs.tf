output "vpc-id" {
  description = "The IDs of the vpc"
  value       = concat(aws_vpc.homework-vpc.*.id, [""])[0]
}

output "public-subnets" {
  description = "The IDs of the public subnets"
  value       = concat(aws_subnet.homework-public-subnet.*.id, [""])[0]
}

output "private-subnets" {
  description = "The IDs of the private subnets"
  value       = concat(aws_subnet.homework-private-subnet.*.id, [""])[0]
}

output "private-subnets-for-eks" {
  description = "The IDs of the private subnets"
  value       = concat(aws_subnet.homework-private-subnet.*.id)
}

output "private-sg-consul" {
  description = "The ID of the private security group"
  value       = aws_security_group.private-sg-consul.*.id
}

output "private-sg-jenkins" {
  description = "The ID of the private security group"
  value       = aws_security_group.private-sg-jenkins.*.id
}

output "public-sg" {
  description = "The ID of the private security group"
  value       = aws_security_group.public-sg.*.id
}

output "private-subnet-az" {
  value = concat(aws_subnet.homework-private-subnet.*.availability_zone)
}

output "public-subnet-az" {
  value = concat(aws_subnet.homework-public-subnet.*.availability_zone)
}

output "aws-keypair" {
  description = "The ID of the private security group"
  value       = concat(aws_key_pair.gen_key.*.key_name, [""])[0]
}

output "bastion-servers" {
  description = "The IPs of the bastion servers"
  value       = concat(aws_instance.bastion-host.*.public_ip)
}
