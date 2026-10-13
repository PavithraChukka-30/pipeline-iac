output "jenkins_url" {
  value = "http://${aws_lb.jenkins.dns_name}"
}

output "instance_id" {
  value = aws_instance.jenkins.id
}