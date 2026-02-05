output "votingApp_asg_arn" {
  value = aws_autoscaling_group.votingApp_asg.arn
}

output "asg_instance_ips" {
  value = data.aws_instances.asg_instances.public_ips
}
