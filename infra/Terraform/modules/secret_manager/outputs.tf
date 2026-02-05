output "db_secrets_arn" {
  value = aws_secretsmanager_secret.db_secrets.arn
}

output "db_secrets_name" {
  value = aws_secretsmanager_secret.db_secrets.name
}

output "password_result" {
  value = random_password.password.result
}