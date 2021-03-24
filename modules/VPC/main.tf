# VPC:
resource "aws_vpc" "homework-vpc" {
  cidr_block = "10.10.0.0/16"  
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "homework-vpc"
    "kubernetes.io/cluster/eks-TheElephant" = "shared"
  }
}

# Public and private subnets
resource "aws_subnet" "homework-public-subnet" {
  vpc_id            = aws_vpc.homework-vpc.id
  count             = length(var.public_cidr_block)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_cidr_block[count.index]

  tags = {
    Name = "public-subnet ${count.index + 1}"
    "kubernetes.io/cluster/eks-TheElephant" = "shared"
    "kubernetes.io/role/elb"                = "1"
  }
}

resource "aws_subnet" "homework-private-subnet" {
  vpc_id            = aws_vpc.homework-vpc.id
  count             = length(var.private_cidr_block)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_cidr_block[count.index]

  tags = {
    Name = "private-subnet ${count.index + 1}"
    "kubernetes.io/cluster/eks-TheElephant" = "shared"
    "kubernetes.io/role/internal-elb"       = "1"
  }
}

# Internet gateway
resource "aws_internet_gateway" "homework-gw" {
  vpc_id = aws_vpc.homework-vpc.id

  tags = {
    Name = "Internet-gateway"
    "kubernetes.io/cluster/eks-TheElephant" = "shared"
  }
}

# NAT gateways
resource "aws_eip" "nat_gateway" {
  vpc   = true
  count = length(var.public_cidr_block)

  # added tags to eips
  tags = {
    Name = "nat-eip ${count.index + 1}"
    "kubernetes.io/cluster/eks-TheElephant" = "shared"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  count         = length(var.public_cidr_block)
  allocation_id = aws_eip.nat_gateway.*.id[count.index]
  subnet_id     = aws_subnet.homework-public-subnet.*.id[count.index]
  depends_on    = [aws_internet_gateway.homework-gw]

  tags = {
    Name = "nat-gw ${count.index + 1}"
    "kubernetes.io/cluster/eks-TheElephant" = "shared"
  }
}

# Routeing
resource "aws_route_table" "route_tables" {
  count  = length(var.route_tables_names)
  vpc_id = aws_vpc.homework-vpc.id

  tags = {
    Name = var.route_tables_names[count.index]
    "kubernetes.io/cluster/eks-TheElephant" = "shared"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.route_tables[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.homework-gw.id
}

resource "aws_route" "private" {
  count                  = length(var.private_cidr_block)
  route_table_id         = aws_route_table.route_tables.*.id[count.index + 1]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gw.*.id[count.index]
}


resource "aws_route_table_association" "to-public-subnet-route" {
  count          = length(var.public_cidr_block)
  subnet_id      = aws_subnet.homework-public-subnet[count.index].id
  route_table_id = aws_route_table.route_tables[0].id
}

resource "aws_route_table_association" "to-private-subnet-route" {
  count          = length(var.private_cidr_block)
  subnet_id      = aws_subnet.homework-private-subnet[count.index].id
  route_table_id = aws_route_table.route_tables[count.index + 1].id
}


# Create keys for the instances
resource "tls_private_key" "gen_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "gen_key" {
  key_name   = "gen_key"
  public_key = tls_private_key.gen_key.public_key_openssh
}

resource "local_file" "gen_key" {
  sensitive_content = tls_private_key.gen_key.private_key_pem
  filename          = "gen_key.pem"
}