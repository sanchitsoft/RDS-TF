# RDS-TF
AWS Aurora RDS cluster with PostgreSQL


Terraform script to create an AWS Aurora RDS cluster with PostgreSQL, including necessary resources like a VPC, subnets, security groups, and a DB subnet group. This script is designed to be simple and suitable for study purposes, aligning with your previous request for a straightforward example. It incorporates parameters from a file (terraform.tfvars) for flexibility, similar to your earlier Jenkinsfile requirement for reading parameters from a file.

Purpose:
This Terraform script creates an AWS Aurora RDS cluster with PostgreSQL, including a VPC, subnets, security group, and a single DB instance. It's designed to be minimal for learning, inspired by your request for a simple Jenkins pipeline for study purposes.

Components:
VPC: Uses the terraform-aws-modules/vpc module to create a VPC with private and database subnets across two availability zones (AZs) for high availability.
Security Group: Allows PostgreSQL traffic (port 5432) from within the VPC and permits all outbound traffic.
Aurora Cluster: Configures an Aurora PostgreSQL cluster with encryption, a 7-day backup retention period, and no final snapshot for simplicity.
Aurora Instance: Provisions one DB instance with a specified instance class (db.t3.medium).
Parameters: Reads project_name, db_username, db_password, etc., from terraform.tfvars, similar to your Jenkinsfile reading from config.properties.

Files:
main.tf: Defines the infrastructure resources (VPC, security group, Aurora cluster, and instance).
variables.tf: Declares variables with defaults where applicable.
terraform.tfvars: Provides parameter values, editable for different deployments.

How to Use:
Prerequisites: Install Terraform, configure AWS CLI with credentials, and have an AWS account.
Steps:
Save the three files (main.tf, variables.tf, terraform.tfvars) in a directory.
Run terraform init to initialize the Terraform workspace.
Run terraform plan to review the execution plan.
Run terraform apply to provision the resources (takes ~5-7 minutes for Aurora).

Check the output cluster_endpoint for the database connection string.
To clean up, run terraform destroy (verify resources are deleted in the AWS Console, as deletion can take time).
Note: Update db_password in terraform.tfvars to a secure value. Avoid hardcoding sensitive data in production.

Security Notes:
The cluster is not publicly accessible (deployed in private subnets).
Storage encryption is enabled for data at rest.
For production, consider using AWS Secrets Manager for db_password and enabling IAM database authentication.

Study Tips:
Experiment by changing instance_class or engine_version in terraform.tfvars.
Add more instances by increasing the count in aws_rds_cluster_instance.
Explore the Terraform AWS provider documentation for additional options like autoscaling or enhanced monitoring.
