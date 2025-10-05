resource "aws_db_instance" "default" {
  identifier = "pg-${var.project_name}-database-1"

  db_name        = var.rds_db_name
  engine         = var.rds_engine
  engine_version = var.rds_engine_version

  username = var.rds_username
  password = var.rds_password

  iam_database_authentication_enabled = false

  availability_zone = var.availability_zone

  publicly_accessible = true
  instance_class      = var.rds_instance_class
  port                = var.rds_port
  allocated_storage   = 20
  storage_type        = "gp3"
  storage_encrypted   = true
  multi_az            = false

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = false

  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true

  performance_insights_enabled = false

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.main.id]

  blue_green_update {
    enabled = false
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "rds-group-${var.project_name}"
  subnet_ids = var.subnets_ids
}

resource "aws_security_group" "main" {
  name        = "${var.project_name}-databases"
  description = "Allow Traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-databases"
  }
}

resource "aws_security_group_rule" "postgresql" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}
