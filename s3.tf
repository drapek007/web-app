resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.environment}-nginx-bucket"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}

# S3 Bucket Policy (Separate Resource)
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:*",
        Resource = [
          "${aws_s3_bucket.my_bucket.arn}",
          "${aws_s3_bucket.my_bucket.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = module.vpc.vpc_id
          }
        }
      }
    ]
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_encryption" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}