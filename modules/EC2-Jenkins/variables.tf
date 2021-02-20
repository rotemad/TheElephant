variable "private_subnet_id" {
  description = "The subnet ID from the network module"
}

variable "jenkins_private_security_group" {
  description = "The ID of the private security group"
}

variable "key_pair" {
  description = "Gen ssh key for login"
}

variable "private_subnet_az" {
}

variable "consul_instance_profile" {
}

/*variable "user_data_master" {
  default = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update
              apt-get install docker-ce docker-ce-cli containerd.io git openjdk-8-jdk -y
              usermod -aG docker ubuntu
              mkdir -p /home/ubuntu/jenkins_home
              chown -R ubuntu:ubuntu /home/ubuntu/jenkins_home
              systemctl enable docker
              systemctl start docker
              docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --env JAVA_OPTS="-Djenkins.install.runSetupWizard=false" jenkins/jenkins
              docker exec -it `docker ps -q` /usr/local/bin/install-plugins.sh github workflow-aggregator docker build-monitor-plugin greenballs
              docker restart `docker ps -q`
              EOF
}

variable "user_data_slave" {
  default = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update
              apt-get install docker-ce docker-ce-cli containerd.io git openjdk-8-jdk -y
              usermod -aG docker ubuntu
              systemctl enable docker
              systemctl start docker
              EOF
}

data "template_file" "consul-agent-install-master" {
  template = file("${path.module}/userdata/consul-agent-jenkins-master.sh")
}

data "template_file" "consul-agent-install-worker" {
  template = file("${path.module}/userdata/consul-agent-jenkins-worker.sh")
}*/