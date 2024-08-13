# Terraform Infrastructure Project

## Overview

This project is a Terraform-based infrastructure deployment framework designed to manage AWS resources. It includes a GitLab CI/CD pipeline that automates the process of formatting, security checking, planning, and applying Terraform configurations.

## Project Structure

- **`provider.tf`**: Configures aws provider.
- **`variables.tf`**: Defines the input variables for the Terraform configuration.
- **`backend.tf`**: Configures the Terraform backend, which uses an S3 bucket to store the state file.
- **`environments/dev.tfvars`**: Variable definitions specific to the development environment.
- **`environments/prod.tfvars`**: Variable definitions specific to the production environment.
- **`.gitlab-ci.yml`**: The GitLab CI/CD pipeline configuration.
- **`rds.tf`**: Add rds database.
- **`ec2.tf`**: Configure ec2 instance with ALB and proper polcies
- **`s3.tf`**: Defines s3 private s3 bucket with versioning and ecnrytpion enabled
- **`prerequisities.tf`**: Configures state - should be done on separete account


## Getting Started

### Prerequisites

Ensure you have the following installed locally:

- [Terraform](https://www.terraform.io/downloads.html) (version 1.5.3 or later)
- [Git](https://git-scm.com/)
- [AWS CLI](https://aws.amazon.com/cli/) (for managing AWS credentials)
- [Python](https://www.python.org/) and `pip` (if running `checkov` locally)

### Setup

1. **Clone the Repository:**
   ```bash
   git clone https://your-gitlab-repo-url.git
   cd your-repo-name

### Additional informations/explanantions
Web application project with ec2 with nginx installed in private subnets, hidden behind ALB. AWS ALB expose aws domain, so in order to use custom domain, route53 record should be added, mapped to the ALB DNS and certificated through ACM can be attached. EC2 can comunicate with RDS and S3 thanks to the attached aws polcies. S3 bucket is our remote state mechanism.
AWS provider will use OIDC mechanism which increase sucurity and aws credentials rotation is not needed. This should be configured between pipeline and AWS, can be use between local env and cloud as well. DB password is generated randomly and kept in secret manager. Only one terraform module was used (vpc), can be used in other places as well.