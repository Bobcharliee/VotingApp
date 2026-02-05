variable "project" {
  description = "The project name"
  type        = string
  default     = "votingApp"
}

variable "aws_region" {
  description = "The aws region to be deployed to"
  type        = string
  default     = "us-east-1"
}

variable "db_username" { type = string }


