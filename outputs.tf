output "jenkins_url" {
  value = "http://${aws_eip.jenkins.public_ip}:8080"
}

output "instance_id" {
  value = aws_instance.jenkins.id
}