variable "project" {
  description = "The project name"
  type        = string
  default     = "votingApp"
}

variable "vpc_id" {
  type = string
}

variable "load_balancer_sg_id" {
  type = string
}

variable "app_server_sg_id" {
  type = string
}