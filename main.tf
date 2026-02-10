# Provider Configuration
# Specifies the AWS provider and region for Terraform to manage resources in.
provider "aws" {
  region = "us-east-1"
}

# Data source to fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Module: VPC
# Creates the Virtual Private Cloud for the WordPress infrastructure
module "vpc" {
  source = "./modules/vpc"
}

# Module: Networking (IGW & Route Tables)
# Creates the Internet Gateway and public route table
module "networking" {
  source = "./modules/networking"
  vpc_id = module.vpc.vpc_id
}

# Module: Subnets
# Creates public and private subnets and associates them with route tables
module "subnets" {
  source         = "./modules/subnets"
  vpc_id         = module.vpc.vpc_id
  route_table_id = module.networking.route_table_id
}

# Module: Security Groups
# Creates security groups for EC2 and RDS instances
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# Module: RDS
# Creates the MySQL RDS instance for WordPress
module "rds" {
  source            = "./modules/rds"
  public_subnet_id  = module.subnets.public_subnet_id
  private_subnet_id = module.subnets.private_subnet_id
  rds_sg_id         = module.security_groups.rds_sg_id
  db_username       = var.db_username
  db_password       = var.db_password
}

# Module: EC2
# Creates the EC2 instance for WordPress with user data configuration
module "ec2" {
  source           = "./modules/ec2"
  public_subnet_id = module.subnets.public_subnet_id
  ec2_sg_id        = module.security_groups.ec2_sg_id
  key_name         = var.key_name
  db_username      = var.db_username
  db_password      = var.db_password
  rds_endpoint     = module.rds.rds_endpoint
  ami_id           = data.aws_ami.amazon_linux_2023.id
}

# Outputs
# Outputs the public IP of the EC2 instance and the RDS endpoint

output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}
