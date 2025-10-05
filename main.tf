terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "security_group" {
  source       = "./modules/sg"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "rds" {
  source             = "./modules/rds"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  subnets_ids        = module.vpc.public_subnet_ids
  rds_engine         = var.rds_engine
  rds_engine_version = var.rds_engine_version
  rds_instance_class = var.rds_instance_class
  rds_port           = var.rds_port
  rds_db_name        = var.rds_db_name
  rds_username       = var.rds_username
  rds_password       = var.rds_password
  availability_zone  = module.vpc.primary_az
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "secrets" {
  source       = "./modules/secrets"
  project_name = var.project_name
  rds_username = var.rds_username
  rds_password = var.rds_password
}

module "iam_glue" {
  source = "./modules/iam/glue"
}

# module "glue" {
#   source                 = "./modules/glue"
#   project_name           = var.project_name
#   primary_az             = module.vpc.primary_az
#   subnet_id              = module.vpc.primary_az
#   vpc_id                 = module.vpc.vpc_id
#   vpc_cidr_block         = module.vpc.vpc_cidr_block
#   glue_role_arn          = module.iam_glue.role_arn
#   jdbc_subprotocol       = var.glue_jdbc_subprotocol
#   jdbc_database_hostname = module.rds.rds_address
#   jdbc_database_port     = var.rds_port
#   jdbc_database_name     = var.rds_db_name
#   jdbc_username          = var.rds_username
#   jdbc_password          = var.rds_password
# }
