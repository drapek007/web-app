# backend.tf

terraform {
  backend "s3" {
    bucket         = var.s3_bucket_name
    key            = "${var.s3_bucket_prefix}/terraform.tfstate"
    region         = var.region
    encrypt        = true
    dynamodb_table = var.dynamodb_table_name
  }
}
