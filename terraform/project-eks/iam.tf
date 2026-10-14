locals {
  # must match the namespace and ServiceAccount in k8s/base
  app_namespace       = "testing-node-server"
  app_service_account = "testing-node-server"

  # created by the bucket module
  app_bucket_arn = "arn:aws:s3:::${local.name_prefix}-app-data"
}

# EKS Pod Identity: pods get short-lived credentials for this role, no access keys anywhere
resource "aws_iam_role" "app" {
  provider = aws.primary
  name     = "${local.name_prefix}-app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

# Only pods running as this ServiceAccount in this namespace get the role
resource "aws_eks_pod_identity_association" "app" {
  provider        = aws.primary
  cluster_name    = local.name_prefix
  namespace       = local.app_namespace
  service_account = local.app_service_account
  role_arn        = aws_iam_role.app.arn
}

# Least privilege: read-only on the app's bucket, nothing else
resource "aws_iam_role_policy" "app" {
  provider = aws.primary
  name     = "read-app-bucket"
  role     = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:ListBucket", "s3:GetObject"]
      Resource = [local.app_bucket_arn, "${local.app_bucket_arn}/*"]
    }]
  })
}