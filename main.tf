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

variable "main_az" {
  type = string
}

variable "master_username" {
  type      = string
  sensitive = true
}

variable "master_password" {
  type      = string
  sensitive = true
}

### Locals ###

locals {
  project_name       = "glueproj"
  region             = var.region
  availability_zones = var.availability_zones
  main_az            = var.main_az
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

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # NAT Gateway route will be added later

  tags = {
    Name = "private-rt"
  }
}


### Subnets ###

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = local.main_az

  # Auto-assign public IPv4 address
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name}-public"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.80.0/24"
  availability_zone = local.availability_zones[0]

  tags = {
    Name = "${local.project_name}-private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = local.availability_zones[1]

  tags = {
    Name = "${local.project_name}-private2"
  }
}

resource "aws_subnet" "private3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.120.0/24"
  availability_zone = local.availability_zones[2]

  tags = {
    Name = "${local.project_name}-private3"
  }
}

# Assign the private route table to the private subnets
resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}


### NAT Gateway ###

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${local.region}.s3"
  vpc_endpoint_type = "Gateway"
  auto_accept       = true
  route_table_ids   = [aws_route_table.private.id]
}

resource "aws_route" "nat_gateway" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.public.id
  destination_cidr_block = "0.0.0.0/0"
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
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id]
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier  = "aurora-cluster"
  engine              = "aurora-mysql"
  engine_mode         = "provisioned"
  engine_version      = "8.0.mysql_aurora.3.02.0"
  availability_zones  = local.availability_zones
  database_name       = "testdb"
  master_username     = var.master_username
  master_password     = var.master_password
  skip_final_snapshot = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  vpc_security_group_ids = [aws_security_group.main.id]
  db_subnet_group_name   = aws_db_subnet_group.default.id
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = 1
  identifier          = "aurora-mysql-instance"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = "db.serverless"
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
  name = "crawler-database"

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
    availability_zone      = local.main_az
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

### Glue Job ###

# resource "aws_glue_job" "glueetl" {
#   name         = "glueetl-job"
#   role_arn     = aws_iam_role.glue.arn
#   glue_version = "3.0"

#   command {
#     script_location = "glueetl"
#   }
# }

### Jumpbox ###

resource "aws_iam_role" "jumpbox" {
  name = "rds-jumpbox-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm-managed-instance-core" {
  role       = aws_iam_role.jumpbox.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

### Key Pair ###
resource "aws_key_pair" "jumpbox" {
  key_name   = "rds-jumpbox"
  public_key = file("${path.module}/id_rsa.pub")
}

### EC2 ###

resource "aws_network_interface" "jumpbox" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.main.id]
}

resource "aws_iam_instance_profile" "jumpbox" {
  name = "rds-jumpbox-profile"
  role = aws_iam_role.jumpbox.id
}

resource "aws_instance" "jumpbox" {
  ami           = "ami-08ae71fd7f1449df1"
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.jumpbox.id
  key_name             = aws_key_pair.jumpbox.key_name

  # Detailed monitoring enabled
  monitoring = true

  # Install MySQL
  user_data = file("${path.module}/mysql.sh")

  network_interface {
    network_interface_id = aws_network_interface.jumpbox.id
    device_index         = 0
  }

  tags = {
    Name = "rds-jumpbox"
  }

}


### Outputs ###

output "instance_ip" {
  value = aws_instance.jumpbox.public_ip
}

output "aurora_endpoint" {
  value = aws_rds_cluster_instance.aurora_instances[0].endpoint
}
