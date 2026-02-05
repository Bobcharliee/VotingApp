output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.votingApp_tg.arn
}

output "aws_lb_target_group_id" {
  value = aws_lb_target_group.votingApp_tg.id
}


output "votingApp_lb_arn" {
  value = aws_lb.votingApp_lb.arn
}

output "load_balancer_logs_id" {
  value = aws_s3_bucket.load_balancer_logs.id
}