resource "aws_iam_role" "ec2_role" {
  name = "ec2_db_rolee"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ec2_role_policy" {
  name = "ec2_role_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = var.db_secrets_arn
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profilee"
  role = aws_iam_role.ec2_role.name
}


resource "aws_launch_template" "votingApp_launch_template" {
  name_prefix   = "votingApp-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = "ubuntu-access-key"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.app_server_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      name = "asg_instance_template"
    }
  }
}


resource "aws_autoscaling_group" "votingApp_asg" {
  name                      = "votingApp_asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = [var.public_subnet]
  

  launch_template {
    id      = aws_launch_template.votingApp_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [var.aws_lb_target_group_arn]
  

  tag {
    key                 = "Name"
    value               = "voting_asg_instance"
    propagate_at_launch = true
  }
}

data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.votingApp_asg.name]
  }
}

resource "local_file" "ansible_inventory" {
  content = <<EOT
[tomcat]
%{ for ip in data.aws_instances.asg_instances.public_ips ~}
${ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/ubuntu-access-key.pem
%{ endfor ~}
EOT
  filename = "${path.module}/../../../inventory.ini"
}






