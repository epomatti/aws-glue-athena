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

module "rds" {
  source             = "./modules/rds"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  subnets_ids        = module.vpc.public_subnet_ids
  rds_engine         = var.rds_engine
  rds_engine_version = var.rds_engine_version
  rds_instance_class = var.rds_instance_class
  rds_port           = var.rds_port
  rds_username       = var.rds_username
  rds_password       = var.rds_password
  availability_zone  = module.vpc.primary_az
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
  aws_region   = var.aws_region
}

# module "iam_blueprint" {
#   source       = "./modules/iam/glue"
#   project_name = var.project_name
#   aws_region   = var.aws_region
# }
