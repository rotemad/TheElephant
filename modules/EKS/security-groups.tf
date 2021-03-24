
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
   ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8","172.16.0.0/16","192.168.0.0/16"]
  }
  ingress {
    description = "Consul port"
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16","172.16.0.0/12","192.168.0.0/16"]
  }
  ingress {
    description = "Consul port"
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8","172.16.0.0/16","192.168.0.0/16"]
  }
  ingress {
    description = "Consul port"
    from_port   = 8301
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8","172.16.0.0/16","192.168.0.0/16"]
  }
  ingress {
    description = "Consul port"
    from_port   = 8301
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8","172.16.0.0/16","192.168.0.0/16"]
  }
  ingress {
    description = "Consul port"
    from_port   = 21000
    to_port     = 21255
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8","172.16.0.0/16","192.168.0.0/16"]
  }
  ingress {
    description = "Consul port"
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8","172.16.0.0/16","192.168.0.0/16"]
  }
  ingress {
    description = "Node exporter port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8","172.16.0.0/16","192.168.0.0/16"]
  }
  ingress {
    description = "Node exporter port"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8","172.16.0.0/16","192.168.0.0/16"]
  }
}
