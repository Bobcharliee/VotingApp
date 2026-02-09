# Create S3 bucket for load balancer access logs
resource "aws_s3_bucket" "load_balancer_logs" {
  bucket = "votingapp-load-balancer-logs-tf-thecloudchief"
}

resource "aws_s3_bucket_policy" "allow_elb_logging" {
  bucket = aws_s3_bucket.load_balancer_logs.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSLogDeliveryWrite"
        Effect    = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.load_balancer_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid       = "AWSLogDeliveryAclCheck"
        Effect    = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action = [
          "s3:GetBucketAcl"
        ]
        Resource = aws_s3_bucket.load_balancer_logs.arn
      }
    ]
  })
}


resource "aws_lb" "votingApp_lb" {
  name               = "votingApp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.load_balancer_sg_id]
  subnets            = [var.private_subnet_1, var.private_subnet_2]

  access_logs {
    bucket  = aws_s3_bucket.load_balancer_logs.bucket
    prefix  = "votingApp-load_balancer_logs"
    enabled = true
  }
}

# Create target group
# Since i am not terminating SSL at the load balancer, I need to ensure my ec2 should have SSL cert installed (Tomcat with https)
# If ec2 isnt listening on 443, health check will fail
resource "aws_lb_target_group" "votingApp_tg" {
  name     = "votingApp-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "votingApp_target_group"
  }
}

resource "aws_lb_listener" "app_server_listener" {
  load_balancer_arn = aws_lb.votingApp_lb.arn
  port              = "8080"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.votingApp_tg.arn
  }
}