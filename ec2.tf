resource "aws_security_group" "ec2" {
  name        = "${var.environment}-ec2-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "${var.environment}-s3_access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.my_bucket.arn,
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  role = aws_iam_role.ec2_role.name
}


# Launch Template for Auto Scaling
resource "aws_launch_template" "nginx" {
  name_prefix   = "${var.environment}-nginx-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  security_group_names = [aws_security_group.ec2.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1.12 -y
              systemctl start nginx
              systemctl enable nginx
              EOF
}

# Auto Scaling Group
resource "aws_autoscaling_group" "nginx_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.nginx.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
}

# Load Balancer
resource "aws_lb" "alb" {
  name               = "${var.environment}-nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2.id]
  subnets            = module.vpc.public_subnets
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name        = "${var.environment}-nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
}

# Load Balancer Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}