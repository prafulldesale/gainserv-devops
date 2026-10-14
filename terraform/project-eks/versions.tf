terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # State bucket and DynamoDB lock table must already exist
  backend "s3" {
    bucket         = "project-eks-teeraform-prod-tfstate"
    key            = "project-eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "project-eks-jarvis-prod"
    encrypt        = true
  }
}