output "votingApp_db_server_arn" {
  value = aws_db_instance.votingApp_db_server.arn
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}

