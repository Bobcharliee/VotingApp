
resource "aws_db_instance" "votingApp_db_server" {
  allocated_storage    = 10
  db_name              = var.db_name
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  parameter_group_name = var.db_parameter_group_name
  username = var.db_username
  password = var.db_password
  skip_final_snapshot  = true
  availability_zone = var.availability_zone[0]
  vpc_security_group_ids = [var.db_server_sg_id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  

  tags = {
    Name = "${var.project}_db_server"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-db-subnet-group"
  subnet_ids = [var.private_subnet_1, var.private_subnet_2]

  tags = {
    Name = "rds-db-subnet-group"
  }
  
}

