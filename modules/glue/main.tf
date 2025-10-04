resource "aws_glue_catalog_database" "aurora" {
  name        = "crawler-database"
  description = "RDS Aurora database"

  create_table_default_permission {
    permissions = ["SELECT"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_glue_connection" "aurora_jdbc" {
  name            = "aurora-jdbc-connection"
  connection_type = "JDBC"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${aws_rds_cluster_instance.aurora_instances[0].endpoint}:3306/${aws_rds_cluster.aurora.database_name}"
    USERNAME            = aws_rds_cluster.aurora.master_username
    PASSWORD            = aws_rds_cluster.aurora.master_password
  }

  physical_connection_requirements {
    availability_zone      = var.primary_az
    subnet_id              = aws_subnet.private1.id
    security_group_id_list = [aws_security_group.main.id]
  }
}

resource "aws_glue_crawler" "aurora" {
  database_name = aws_glue_catalog_database.aurora.name
  name          = "rds-aurora-crawler"
  role          = aws_iam_role.glue.arn

  jdbc_target {
    connection_name = aws_glue_connection.aurora_jdbc.name
    path            = "${aws_rds_cluster.aurora.database_name}/%"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AWSGlueServiceRole,
    aws_iam_role_policy_attachment.AmazonS3FullAccess,
    aws_iam_role_policy_attachment.AwsGlueConsoleFullAccess,
    aws_iam_role_policy_attachment.AmazonRDSFullAccess,
  ]
}
