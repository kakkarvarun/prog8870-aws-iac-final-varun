variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ca-central-1"
}

variable "project_name" {
  description = "Prefix used for tagging and naming"
  type        = string
  default     = "prog8870-final-varun"
}

variable "s3_bucket_names" {
  description = "List of 4 unique S3 bucket names for Terraform"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR for main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet (EC2)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet1_cidr" {
  description = "CIDR for DB subnet 1"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_subnet2_cidr" {
  description = "CIDR for DB subnet 2"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zones" {
  description = "AZs used for subnets"
  type        = list(string)
  default     = ["ca-central-1a", "ca-central-1b"]
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "ec2_key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into EC2 (e.g. your_ip/32)"
  type        = string
}

variable "allowed_db_cidr" {
  description = "CIDR allowed to access MySQL (e.g. your_ip/32)"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "DB storage (GB)"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0.35"
}

variable "db_instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t3.micro"
}
