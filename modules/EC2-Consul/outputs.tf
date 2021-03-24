output "consul-servers" {
  description = "The IPs of consul servers"
  value       = concat(aws_instance.consul-servers.*.private_ip)
}

output "consul-instance-profile" {
  description = "Consul's instance profile"
  value       = aws_iam_instance_profile.consul-join.id
}

output "ec2-admin-arn" {
  description = "ec2-all-for-k8s"
  value       = aws_iam_instance_profile.consul-join.arn
}