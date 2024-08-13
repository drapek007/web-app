# variables.tf

variable "environment" {
  description = "The environment name (dev or prod)"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy in"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "db_instance_class" {
  description = "The instance class for RDS"
  type        = string
}

variable "db_allocated_storage" {
  description = "The allocated storage for RDS"
  type        = number
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
}

variable "s3_bucket_prefix" {
  description = "The prefix for the state files in the S3 bucket"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}
