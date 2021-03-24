output "elk-server" {
  description = "The IPs of consul servers"
  value       = concat(aws_instance.elk.*.private_ip)
}