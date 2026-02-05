variable "project" {
  description = "The project name"
  type        = string
  default     = "votingApp"
}

variable "ami_id" {
  description = "The ami id used for the ec2"
  type        = string
  default     = "ami-07ff62358b87c7116"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}


variable "load_balancer_sg_id" {
  type = string
}


variable "aws_lb_target_group_arn" {
  type = string
}

variable "public_subnet" {
  type = string
}

variable "db_secrets_arn" {
  type = string
}

variable "app_server_sg_id" {
  type = string
}