# Create a public secutiry group with HTTP,SSH and ICMP allowed:
resource "aws_security_group" "public-sg" {
  name   = "homework-public-sg"
  vpc_id = aws_vpc.homework-vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }
  ingress {
    description = "Allow ICMP"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "public-sg"
  }
}

# Create a private group for Consul:
resource "aws_security_group" "private-sg-consul" {
  name   = "homework-private-sg-consul"
  vpc_id = aws_vpc.homework-vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8301
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8301
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  ingress {
    description = "node-exporter port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-sg-consul"
  }
}

# Create a private group for Jenkins:
resource "aws_security_group" "private-sg-jenkins" {
  name   = "homework-private-sg-jenkins"
  vpc_id = aws_vpc.homework-vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "jenkins 8080 port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "jenkins 50000 port"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "node-exporter port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-sg-consul"
  }
}

# Create a private group for Prometheus
resource "aws_security_group" "private-sg-prometheus" {
  name        = "homework-private-sg-prometheus"
  description = "Security group for monitoring server"
  vpc_id      = aws_vpc.homework-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP from control host IP
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  # Allow all SSH External
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["10.10.0.0/16"]
  }

  # Allow all traffic to HTTP port 3000
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "node-exporter port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  # Allow all traffic to HTTP port 9090
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "TCP"
    cidr_blocks = ["10.10.0.0/16"]
  }
}

# Create a private group for ELK:
resource "aws_security_group" "private-sg-elk" {
  name   = "homework-private-sg-elk"
  vpc_id = aws_vpc.homework-vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "node-exporter port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "node-exporter port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "Elasticsearch port"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

    ingress {
    description = "Elasticsearch port"
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  ingress {
    description = "Filebeats/Logstash port"
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16","172.16.0.0/16","192.168.0.0/16"]
  }

  ingress {
    description = "Kibana port"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-sg-elk"
  }
}

# Create a private group for Mysql
resource "aws_security_group" "private-sg-mysql" {
  name        = "homework-private-sg-mysql"
  description = "Security group for monitoring server"
  vpc_id      = aws_vpc.homework-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "node-exporter port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }
}