output "consul-servers" {
  description = "The IPs of consul servers"
  value       = concat(aws_instance.consul-servers.*.private_ip)
}