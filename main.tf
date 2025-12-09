############################################
# Terraform meta and AWS provider versions
############################################

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

############################################
# S3 Buckets (Module 1 - Terraform)
############################################

resource "aws_s3_bucket" "project_buckets" {
  for_each = toset(var.s3_bucket_names)

  bucket = each.value

  tags = {
    Name        = "${var.project_name}-${each.value}"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "project_buckets" {
  for_each = aws_s3_bucket.project_buckets

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "project_buckets" {
  for_each = aws_s3_bucket.project_buckets

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################
# VPC & Networking (Module 2 foundation)
############################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
  }
}

resource "aws_subnet" "db_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.db_subnet1_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project_name}-db-subnet-1"
    Project = var.project_name
  }
}

resource "aws_subnet" "db_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.db_subnet2_cidr
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project_name}-db-subnet-2"
    Project = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

############################################
# Security Groups
############################################

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow SSH to EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ec2-sg"
    Project = var.project_name
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow MySQL access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MySQL from allowed CIDR"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.allowed_db_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-rds-sg"
    Project = var.project_name
  }
}

############################################
# EC2 Instance (Module 2)
############################################

resource "aws_instance" "web" {
  ami                         = var.ec2_ami_id
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.ec2_key_name
  associate_public_ip_address = true

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
    Role    = "demo-web"
  }
}

output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.web.public_ip
}

############################################
# RDS MySQL (Module 3)
############################################

resource "aws_db_subnet_group" "rds_subnets" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet1.id, aws_subnet.db_subnet2.id]

  tags = {
    Name    = "${var.project_name}-db-subnet-group"
    Project = var.project_name
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "${var.project_name}-mysql"
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  multi_az               = false

  tags = {
    Name    = "${var.project_name}-mysql"
    Project = var.project_name
  }
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.mysql.endpoint
}
