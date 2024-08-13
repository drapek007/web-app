resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow PostgreSQL traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Store RDS Password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "rds-db-password"
}

# Generate a random password and store it in Secrets Manager
resource "random_password" "rds_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "admin",  # You can also dynamically generate this if needed
    password = random_password.rds_password.result
  })
}

# RDS PostgreSQL
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.environment}-postgres-db"
  engine                 = "postgres"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = "mydatabase"
  username               = jsondecode(aws_secretsmanager_secret_version.db_password_version.secret_string)["username"]
  password               = jsondecode(aws_secretsmanager_secret_version.db_password_version.secret_string)["password"]
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}
