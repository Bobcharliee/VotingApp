output "application_server" {
  description = "public ip address of the application servers"
    value = aws_instance.app_server[*].public_ip
}

output "logic_server" {
  description = "private ip address of the logic server"
    value = aws_instance.logic_server.*.private_ip
}

output "database_server" {
  description = "private ip address of the database server"
    value = aws_instance.db_server.*.private_ip
}

