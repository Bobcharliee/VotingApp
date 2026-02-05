output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.votingApp_vpc.id
}

output "private_subnets" {
  value = [for subnet in aws_subnet.private_subnets : subnet.id]
}

output "public_subnet" {
  value = aws_subnet.public_subnet.id
}

output "votingApp_igw" {
  value = aws_internet_gateway.votingApp_igw.id
}

output "nat_eip" {
  value = aws_eip.nat_eip.id
}

output "votingApp_nat_gw" {
  value = aws_nat_gateway.votingApp_nat_gw.id
}

output "private_subnet_1" {
  value = aws_subnet.private_subnets[0].id
}

output "private_subnet_2" {
  value = aws_subnet.private_subnets[1].id
}