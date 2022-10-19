terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    atlas = {
      source  = "ariga/atlas"
      version = "0.3.0-pre.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

// Fetch the list of availability zones from the current region.
data "aws_availability_zones" "available" {
  state = "available"
}

// Provision a VPC and subnets in these AZs.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.16.1"

  name                 = "atlas-rds-demo"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

// Create a DB subnet to provision the database.
resource "aws_db_subnet_group" "atlas" {
  name       = "atlas-rds-demo"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Demo"
  }
}

// Generate a random password for our db user.
resource "random_password" "password" {
  length  = 16
  special = true
}

// Security group which allows *public access* to our database.
// DO NOT use this in production.
resource "aws_security_group" "rds" {
  name   = "atlas-demo"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "atlas"
  }
}

// Our RDS-based MySQL 8 instance.
resource "aws_db_instance" "atlas-demo" {
  identifier             = "atlas-demo"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0.28"
  username               = "atlas"
  password               = random_password.password.result
  db_subnet_group_name   = aws_db_subnet_group.atlas.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = "default.mysql8.0"
  publicly_accessible    = true
  skip_final_snapshot    = true
}

locals {
  dev_db_url = "mysql://root:pass@localhost:3306/example"
}

// Load the schema from file and normalize it using the dev database.
data "atlas_schema" "hello" {
  dev_db_url = local.dev_db_url
  src        = file("schema.hcl")
}

// Apply the normalized schema to the RDS-managed database.
resource "atlas_schema" "hello" {
  hcl        = data.atlas_schema.hello.hcl
  dev_db_url = local.dev_db_url
  url        = "mysql://${aws_db_instance.atlas-demo.username}:${urlencode(random_password.password.result)}@${aws_db_instance.atlas-demo.endpoint}/"
}
