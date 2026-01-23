# Create VPC
resource "aws_vpc" "votingApp_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.project}_VPC"
  }
}

# Create Public Subnet_1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.votingApp_vpc.id
  region                  = var.aws_region
  availability_zone       = "${var.availability_zone[0]}"
  cidr_block              = "${var.public_subnet_cidrs[0]}"
  map_public_ip_on_launch = true
    tags = {
        Name = "${var.project}_public_subnet_1"
    }
}

# Create Public Subnet_2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.votingApp_vpc.id
  region                  = var.aws_region
  availability_zone       = "${var.availability_zone[1]}"
  cidr_block              = "${var.public_subnet_cidrs[1]}"
  map_public_ip_on_launch = true
    tags = {
        Name = "${var.project}_public_subnet_2"
    }
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.votingApp_vpc.id
  region            = var.aws_region
  availability_zone = "${var.availability_zone[0]}"
  cidr_block        = var.private_subnet_cidrs
    tags = {
        Name = "${var.project}_private_subnet"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "votingApp_igw" {
  vpc_id = aws_vpc.votingApp_vpc.id
    tags = {
        Name = "${var.project}_IGW"
    }
}

# Create Public Route Table
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.votingApp_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.votingApp_igw.id
    }

    tags = {
        Name = "${var.project}_public_rt"
    }
}


# Associate Public Subnet_1 with Public Route Table
resource "aws_route_table_association" "public_rt_assoc_1" {
    subnet_id      = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_rt.id
}

# Associate Public Subnet_2 with Public Route Table
resource "aws_route_table_association" "public_rt_assoc_2" {
    subnet_id      = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_rt.id
}

# Create NAT Gateway
# First we need an Elastic IP for the NAT Gateway in the public subnet
resource "aws_eip" "nat_eip" {
    domain   = "vpc"
    tags = {
        Name = "${var.project}_NAT_EIP"
    }
}

# Now create the NAT Gateway in any of the two public subnets
# I am creating it in public_subnet_1
resource "aws_nat_gateway" "votingApp_nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet_1.id
    tags = {
        Name = "${var.project}_NAT_GW"
    }
}

# Create Private Route Table  
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.votingApp_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.votingApp_nat_gw.id
    }

    tags = {
        Name = "${var.project}_private_rt"
    }
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_rt_assoc" { 
    subnet_id      = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}

# Security Group for Application load balancer
resource "aws_security_group" "load_balancer_sg" {
  name        = "${var.project}_load_balancer_sg"
  description = "Security group for application load balancer"
    vpc_id      = aws_vpc.votingApp_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "${var.project}_load_balancer_sg"
    }
}

# Security Group for Application servers
resource "aws_security_group" "app_server_sg" {
  name        = "${var.project}_app_server_sg"
  description = "Security group for application servers"
    vpc_id      = aws_vpc.votingApp_vpc.id
    ingress {
        description = "Allow HTTP from Load Balancer"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.load_balancer_sg.id]
    }

    ingress {
        description = "Allow HTTPS from Load Balancer"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        security_groups = [aws_security_group.load_balancer_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "${var.project}_app_server_sg"
    }
}

# Security Group for Logic server
resource "aws_security_group" "logic_server_sg" {
  name        = "${var.project}_logic_server_sg"
  description = "Security group for logic server"
    vpc_id      = aws_vpc.votingApp_vpc.id
    ingress {
        description = "Allow HTTP from Application servers"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.app_server_sg.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "${var.project}_logic_server_sg"
    }
}

# Security Group for Database server
resource "aws_security_group" "db_server_sg" {
  name        = "${var.project}_db_server_sg"
  description = "Security group for database server"
    vpc_id      = aws_vpc.votingApp_vpc.id
    ingress {
        description = "Allow MySQL from Logic server"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        security_groups = [aws_security_group.logic_server_sg.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "${var.project}_db_server_sg"
    }
}

