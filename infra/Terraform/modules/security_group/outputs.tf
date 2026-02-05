output "app_server_sg_id" {
  description = "The ID of the application server security group"
  value       = aws_security_group.app_server_sg.id
  
}

output "load_balancer_sg_id" {
  description = "The ID of the load balancer security group"
  value       = aws_security_group.load_balancer_sg.id
}

output "db_server_sg_id" {
  description = "The ID of the database server security group"
  value       = aws_security_group.db_server_sg.id
}