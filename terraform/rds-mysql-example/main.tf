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

data "aws_availability_zones" "available" {
  state = "available"
}

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

resource "aws_db_subnet_group" "atlas" {
  name       = "atlas-rds-demo"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Demo"
  }
}

resource "random_password" "password" {
  length  = 16
  special = true
}

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
  parameter_group_name   = "default.mysql5.7"
  publicly_accessible    = true
  skip_final_snapshot    = true
}

data "atlas_schema" "hello" {
  dev_db_url = "mysql://root:pass@localhost:3306/example"
  src        = file("schema.hcl")
}

resource "atlas_schema" "hello" {
  hcl        = data.atlas_schema.hello.hcl
  dev_db_url = "mysql://root:pass@localhost:3306/example"
  url        = "mysql://${aws_db_instance.atlas-demo.username}:${urlencode(random_password.password.result)}@${aws_db_instance.atlas-demo.endpoint}/"
}