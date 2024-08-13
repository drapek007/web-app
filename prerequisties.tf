provider "aws" {
  region = "us-west-2"  # Replace with your desired region
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket"  # Replace with your desired bucket name

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "retain-latest-version"
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  tags = {
    Name        = "terraform-state-bucket"
    Environment = "dev"
  }
}

# DynamoDB Table for Terraform State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "my-terraform-lock-table"  # Replace with your desired table name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

}

