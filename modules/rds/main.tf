resource "aws_db_subnet_group" "rds" {
  name       = "${var.env}-rds-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.env}-rds-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                   = var.db_name
  username               = var.username
  password               = var.password
  multi_az               = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name = "${var.env}-${var.db_name}-rds"
  }
}