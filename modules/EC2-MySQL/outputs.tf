output "mysql-server" {
  description = "The IPs of consul servers"
  value       = concat(aws_instance.mysql.*.private_ip)
}