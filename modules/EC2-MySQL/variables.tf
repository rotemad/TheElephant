variable "private_subnet_id" {
  description = "The subnet ID from the network module"
}

variable "mysql_private_security_group" {
  description = "The ID of the private security group"
}

variable "key_pair" {
  description = "Gen ssh key for login"
}

variable "private_subnet_az" {
}

variable "consul_instance_profile" {
}