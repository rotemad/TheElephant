# Create the jenkins-master
resource "aws_instance" "jenkins-master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_pair
  count         = 1
  subnet_id     = var.private_subnet_id
  #availability_zone      = var.private_subnet_az[count.index]
  vpc_security_group_ids = var.jenkins_private_security_group
  user_data              = file("${path.module}/userdata/consul-agent-jenkins-master.sh")
  iam_instance_profile   = var.consul_instance_profile
  depends_on             = [var.consul_instance_profile]

  tags = {
    Name = "elephant-jenkins-master-${count.index + 1}"
  }
}

# Create the jenkins-slaves
resource "aws_instance" "jenkins-slaves" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_pair
  count         = 2
  subnet_id     = var.private_subnet_id
  #availability_zone      = var.private_subnet_az[count.index]
  vpc_security_group_ids = var.jenkins_private_security_group
  user_data              = file("${path.module}/userdata/consul-agent-jenkins-worker.sh")
  iam_instance_profile   = var.consul_instance_profile
  depends_on             = [var.consul_instance_profile]

  tags = {
    Name = "elephant-jenkins-slave-${count.index + 1}"
  }
}