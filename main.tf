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
