resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "csye6225-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "rds_instance" {
  identifier             = "csye6225"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_name                = "csye6225"
  parameter_group_name   = aws_db_parameter_group.db_params.name
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg[0].id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false
  storage_encrypted      = true
}
