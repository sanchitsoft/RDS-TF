# Configure the AWS provider
provider "aws" {
  region = var.region
}

# Data source for availability zones
data "aws_availability_zones" "available" {}

# Local variables for naming and configuration
locals {
  name = var.project_name
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

# VPC module for network setup
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs              = local.azs
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  database_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  create_database_subnet_group = true
  database_subnet_group_name   = "${local.name}-db-subnet-group"

  tags = {
    Project = local.name
  }
}

# Security group for Aurora cluster
resource "aws_security_group" "aurora_sg" {
  name        = "${local.name}-aurora-sg"
  description = "Security group for Aurora PostgreSQL cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "PostgreSQL access from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = local.name
  }
}

# Aurora PostgreSQL cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "${local.name}-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = var.engine_version
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = module.vpc.database_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  backup_retention_period = 7
  skip_final_snapshot     = true
  storage_encrypted       = true

  tags = {
    Project = local.name
  }
}

# Aurora cluster instance
resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = 1
  identifier         = "${local.name}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora_cluster.engine
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version

  tags = {
    Project = local.name
  }
}

# Output cluster endpoint for connectivity
output "cluster_endpoint" {
  value       = aws_rds_cluster.aurora_cluster.endpoint
  description = "The endpoint for connecting to the Aurora PostgreSQL cluster"
}
