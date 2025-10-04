variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type      = string
  sensitive = true
}
