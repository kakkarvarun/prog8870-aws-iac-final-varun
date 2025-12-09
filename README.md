# PROG8870 – AWS Infrastructure Automation (Terraform + CloudFormation)

This repository contains my final project for PROG8870:
- Terraform: S3, VPC, EC2, RDS (MySQL)
- CloudFormation: S3, EC2, RDS (YAML templates)

# PROG8870 – AWS Infrastructure Automation (Terraform + CloudFormation)

## Overview

This project demonstrates Infrastructure as Code (IaC) using **Terraform** and **AWS CloudFormation**:

- Terraform:
  - 4 private S3 buckets with versioning and Public Access Block
  - Custom VPC with public subnet, Internet Gateway, route table
  - EC2 instance with SSH access on port 22
  - RDS MySQL instance (db.t3.micro) in a dedicated DB subnet group
- CloudFormation (YAML):
  - 3 S3 buckets with versioning and PublicAccessBlockConfiguration
  - EC2 instance + VPC + networking
  - RDS MySQL instance with public access enabled and SG on port 3306

## Repo Structure

- `main.tf` – Terraform resources (S3, VPC, EC2, RDS)
- `provider.tf` – AWS provider configuration
- `backend.tf` – Local backend (terraform.tfstate on laptop)
- `variables.tf` – All Terraform variables
- `vars.tfvars` – Variable values (used with `-var-file`)
- `cloudformation/s3-buckets.yml` – S3 CloudFormation stack
- `cloudformation/ec2-vpc.yml` – EC2 + VPC CloudFormation stack
- `cloudformation/rds-mysql.yml` – RDS MySQL CloudFormation stack

## How to Run Terraform

1. Install Terraform and AWS CLI.
2. Configure AWS credentials (`aws configure`).
3. Update `vars.tfvars`:
   - Unique S3 bucket names
   - `ec2_ami_id` (valid in your region)
   - `ec2_key_name`
   - Your IP in `allowed_ssh_cidr` and `allowed_db_cidr`
4. Initialize and apply:

```bash
terraform init
terraform fmt
terraform plan -var-file="vars.tfvars"
terraform apply -var-file="vars.tfvars"


5. Useful outputs:

ec2_public_ip – used for SSH

rds_endpoint – MySQL endpoint

How to Run CloudFormation

Go to AWS CloudFormation console.

For each template:

cloudformation/s3-buckets.yml

cloudformation/ec2-vpc.yml

cloudformation/rds-mysql.yml

Create stack → upload template → fill parameters → create.

Verify resources in S3, EC2, and RDS consoles.

Cleanup

To avoid ongoing charges:

terraform destroy -var-file="vars.tfvars"

Then delete CloudFormation stacks (S3, EC2, RDS) from the console.

