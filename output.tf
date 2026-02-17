output "public_ip" {
  value = aws_instance.task_manager.public_ip
}

output "app_url" {
  value = "http://${aws_instance.task_manager.public_ip}:3000"
}
