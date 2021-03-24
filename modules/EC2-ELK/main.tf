resource "aws_instance" "elk" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  key_name      = var.key_pair
  count         = 1
  subnet_id     = var.private_subnet_id
  #availability_zone      = var.private_subnet_az[count.index]
  vpc_security_group_ids = var.elk_private_security_group
  user_data              = file("${path.module}/userdata/elk.sh")
  iam_instance_profile   = var.consul_instance_profile
  depends_on             = [var.consul_instance_profile]

  tags = {
    Name = "elephant-elk-${count.index + 1}"
  }
}
