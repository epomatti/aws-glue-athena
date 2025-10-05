resource "aws_glue_catalog_database" "aurora" {
  name        = "crawler-database"
  description = "RDS database"

  create_table_default_permission {
    permissions = ["SELECT"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_glue_connection" "jdbc" {
  name            = "jdbc-connection"
  connection_type = "JDBC"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:${var.jdbc_subprotocol}://${var.jdbc_database_hostname}:${var.jdbc_database_port}/${var.jdbc_database_name}"
    USERNAME            = var.jdbc_username
    PASSWORD            = var.jdbc_password
  }

  physical_connection_requirements {
    availability_zone      = var.primary_az
    subnet_id              = var.subnet_id
    security_group_id_list = [aws_security_group.main.id]
  }
}

resource "aws_glue_crawler" "aurora" {
  database_name = aws_glue_catalog_database.aurora.name
  name          = "rds-crawler"
  role          = var.glue_role_arn

  jdbc_target {
    connection_name = aws_glue_connection.jdbc.name
    path            = "${var.jdbc_database_name}/%"
  }
}

### Security Group for RDS access ###
resource "aws_security_group" "main" {
  name        = "${var.project_name}-glue"
  description = "Allow Traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-glue"
  }
}

resource "aws_security_group_rule" "postgresql" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "mysql" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}
