resource "aws_secretsmanager_secret" "glue_connector" {
  name                    = "/${var.project_name}/blue/jdbc-connector"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "current" {
  secret_id = aws_secretsmanager_secret.glue_connector.id
  secret_string = jsonencode({
    username = "${var.rds_username}"
    password = "${var.rds_password}"
  })
}
