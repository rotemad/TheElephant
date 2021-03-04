output "prometheus-server" {
  description = "The IPs of consul servers"
  value       = concat(aws_instance.prometheus-server.*.private_ip)
}