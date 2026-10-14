locals {
  # Consistent naming across resources, e.g. jarvis-prod-vpc
  name_prefix = "${var.project}-${var.environment}"

  # Common tags applied through the AWS provider
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}