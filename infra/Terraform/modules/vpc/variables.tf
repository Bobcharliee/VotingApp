variable "project" {
  description = "The project name"
  type = string
  default = "votingApp"
}

variable "aws_region" {
  description = "The aws region to be deployed to"
  type = string
  default = "us-east-1"
}

variable "availability_zone" {
  description = "list of availability zones to be deployed to"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "public subnet CIDR blocks"
  type = string
  default = "10.0.3.0/24"
}
variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "ami_id" {
  description = "The ami id used for the ec2"
  type = string
    default = "ami-07ff62358b87c7116"
}


variable "allowed_ipv4_cidr" {
  description = "the ipv4 cidr allowed to ssh into ec2"
    type = string
    default = "0.0.0.0/0"
}

variable "allowed_ipv6_cidr" {
  description = "the ipv6 cidr allowed to ssh into ec2"
    type = string
    default = "::/0"
}
