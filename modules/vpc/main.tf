locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
  primary_az         = local.availability_zones[0]
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  # Enable DNS hostnames 
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.project_name}"
  }
}

### Internet Gateway ###
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${var.project_name}"
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

  tags = {
    Name = "private-rt"
  }
}


### Subnets ###

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = local.availability_zones[0]

  # Auto-assign public IPv4 address
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = local.availability_zones[1]

  # Auto-assign public IPv4 address
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.80.0/24"
  availability_zone = local.availability_zones[0]

  tags = {
    Name = "${var.project_name}-private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.81.0/24"
  availability_zone = local.availability_zones[1]

  tags = {
    Name = "${var.project_name}-private2"
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

### NAT Gateway ###

# resource "aws_eip" "nat_gateway" {
#   vpc = true

# }

# resource "aws_nat_gateway" "public" {
#   allocation_id = aws_eip.nat_gateway.id
#   subnet_id     = aws_subnet.public.id

#   tags = {
#     Name = "nat-gateway"
#   }

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.main]
# }

# resource "aws_route" "nat_gateway" {
#   route_table_id         = aws_route_table.private.id
#   nat_gateway_id         = aws_nat_gateway.public.id
#   destination_cidr_block = "0.0.0.0/0"
# }
