variable "vpc_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "subnets_ids" {
  type = list(string)
}

variable "rds_engine" {
  type = string
}

variable "rds_engine_version" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_port" {
  type = number
}

variable "rds_db_name" {
  type = string
}

variable "rds_username" {
  type      = string
  sensitive = true
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "availability_zone" {
  type = string
}
