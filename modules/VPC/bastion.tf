# Get the AMI data
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion-host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.gen_key.id
  #count                  = length(var.public_cidr_block)
  count     = 1
  subnet_id = aws_subnet.homework-public-subnet.*.id[count.index]
  #availability_zone      = var.private_subnet_az[count.index]
  vpc_security_group_ids      = [aws_security_group.public-sg.id]
  associate_public_ip_address = "true"


  tags = {
    Name = "elephant-bastion-host-${count.index + 1}"
  }
}
