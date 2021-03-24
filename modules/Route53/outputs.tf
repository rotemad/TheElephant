output "route53-zone" {
  description = "route53 zone id"
  value       = aws_route53_zone.elephant-internal.id
}