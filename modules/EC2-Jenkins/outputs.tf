output "jenkins-master" {
  description = "The IP of jenkins's master server"
  value       = concat(aws_instance.jenkins-master.*.private_ip)
}
output "jenkins-workers" {
  description = "The IPs of jenkins's slaves servers"
  value       = concat(aws_instance.jenkins-slaves.*.private_ip)
}
