### General ###
variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

### RDS ###
variable "rds_engine" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_port" {
  type = number
}

variable "rds_username" {
  type      = string
  sensitive = true
}

variable "rds_db_name" {
  type = string
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_engine_version" {
  type = string
}

### Glue ###
variable "glue_jdbc_subprotocol" {
  type = string
}
