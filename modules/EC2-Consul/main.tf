# Create the consul-servers
resource "aws_instance" "consul-servers" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.key_pair
  count                  = 3
  subnet_id              = var.private_subnet_id
  #availability_zone      = var.private_subnet_az[count.index]
  vpc_security_group_ids = var.consul_private_security_group
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data              = file("${path.module}/userdata/consul-server.sh")

  tags = {
    Name          = "consul-server-${count.index + 1}"
    consul-server = "true"
  }
}

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "opsschool-consul-join"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "opsschool-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/templates/policies/describe-instances.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "opsschool-consul-join"
  roles      = [aws_iam_role.consul-join.name]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name = "opsschool-consul-join"
  role = aws_iam_role.consul-join.name
}