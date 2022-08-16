provider "aws" {
  region = local.region
  assume_role {
    role_arn = var.assume_role_arn
  }
}

### Variables ###

variable "assume_role_arn" {
  type = string
}

variable "region" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

### Locals ###

locals {
  project_name       = "glueproj"
  region             = var.region
  availability_zones = var.availability_zones
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  # Enable DNS hostnames 
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${local.project_name}"
  }
}

### Internet Gateway ###

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${local.project_name}"
  }
}

### Route Tables ###

resource "aws_default_route_table" "internet" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "internet-rt"
  }
}

### Subnets ###

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.80.0/24"
  availability_zone = local.availability_zones[0]

  # Auto-assign public IPv4 address
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name}-public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = local.availability_zones[1]

  # Auto-assign public IPv4 address
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name}-public2"
  }
}

resource "aws_subnet" "public3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.120.0/24"
  availability_zone = local.availability_zones[2]

  # Auto-assign public IPv4 address
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name}-public3"
  }
}


### Security Group ###

# Clean-up Default
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "main" {
  name        = "${local.project_name}-public-sc"
  description = "Allow Traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.project_name}-public-sc"
  }
}

resource "aws_security_group_rule" "all_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}

### RDS Aurora ###

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier  = "aurora-cluster"
  engine              = "aurora-mysql"
  engine_version      = "8.0.mysql_aurora.3.02.0"
  availability_zones  = local.availability_zones
  database_name       = "testdb"
  master_username     = "etluser"
  master_password     = "passw0rd"
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.main.id]
  db_subnet_group_name   = aws_db_subnet_group.default.id
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = 1
  identifier          = "aurora-mysql-instance"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.aurora.engine
  engine_version      = aws_rds_cluster.aurora.engine_version
  publicly_accessible = true
}


### S3 ###

resource "aws_s3_bucket" "main" {
  bucket = "${local.project_name}-${local.region}-epomatti"

  tags = {
    Name = "Sandbox Bucket"
  }
}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


### Glue ###

data "aws_iam_policy" "AWSGlueServiceRole" {
  name = "AWSGlueServiceRole"
}

data "aws_iam_policy" "AmazonS3FullAccess" {
  name = "AmazonS3FullAccess"
}

data "aws_iam_policy" "AwsGlueConsoleFullAccess" {
  arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

data "aws_iam_policy" "AmazonRDSFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role" "glue" {
  name = "GlueRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole" {
  role       = aws_iam_role.glue.name
  policy_arn = data.aws_iam_policy.AWSGlueServiceRole.arn
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  role       = aws_iam_role.glue.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AwsGlueConsoleFullAccess" {
  role       = aws_iam_role.glue.name
  policy_arn = data.aws_iam_policy.AwsGlueConsoleFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AmazonRDSFullAccess" {
  role       = aws_iam_role.glue.name
  policy_arn = data.aws_iam_policy.AmazonRDSFullAccess.arn
}

resource "aws_glue_catalog_database" "aurora" {
  name = "aurora-catalog-database"

  create_table_default_permission {
    permissions = ["SELECT"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_glue_connection" "aurora_jdbc" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${aws_rds_cluster_instance.aurora_instances[0].endpoint}/${aws_rds_cluster.aurora.database_name}"
    USERNAME            = aws_rds_cluster.aurora.master_username
    PASSWORD            = aws_rds_cluster.aurora.master_password
  }

  name = "aurora-jdbc-connection"
}

resource "aws_glue_crawler" "aurora" {
  database_name = aws_glue_catalog_database.aurora.name
  name          = "aurora-crawler"
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


### Outputs ###

output "aurora_endpoint" {
  value = aws_rds_cluster_instance.aurora_instances[0].endpoint
}
