variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "glue_role_arn" {
  type = string
}

variable "jdbc_subprotocol" {
  type = string
}

variable "jdbc_database_hostname" {
  type = string
}

variable "jdbc_database_port" {
  type = number
}

variable "jdbc_database_name" {
  type = string
}

variable "jdbc_username" {
  type = string
}

variable "jdbc_password" {
  type      = string
  sensitive = true
}

variable "primary_az" {
  type = string
}

variable "subnet_id" {
  type = string
}
