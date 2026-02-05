# Create VPC
resource "aws_vpc" "votingApp_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.project}_VPC"
  }
}

# Create 2 Private Subnets
resource "aws_subnet" "private_subnets" {
    count = length(var.availability_zone)
  vpc_id                  = aws_vpc.votingApp_vpc.id
  region                  = var.aws_region
  availability_zone       = var.availability_zone[count.index]
  cidr_block              = var.private_subnet_cidrs[count.index]
  
    tags = {
        Name = "private_subnet_${var.availability_zone[count.index]}"
    }
}

# Create 1 Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.votingApp_vpc.id
  region            = var.aws_region
  availability_zone = "${var.availability_zone[0]}"
  cidr_block        = var.public_subnet_cidrs

  map_public_ip_on_launch = true
    tags = {
        Name = "${var.project}_public_subnet"
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


# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id      = aws_subnet.public_subnet.id
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

# Now create the NAT Gateway in our public subnet
resource "aws_nat_gateway" "votingApp_nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet.id
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
    count = length(var.availability_zone)
    subnet_id      = aws_subnet.private_subnets[count.index].id
    route_table_id = aws_route_table.private_rt.id
}



