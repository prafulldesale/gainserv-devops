variable "project" {
  description = "Project name, first part of every resource name"
  type        = string
  default     = "jarvis"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"

  # Restrict environment values to avoid invalid resource naming and configuration.
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "aws_region" {
  description = "Main region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Second region (DR copies)"
  type        = string
  default     = "us-west-2"
}

# one networking module per entry; a new VPC is a new key, existing ones are untouched
variable "networks" {
  description = "VPCs to create, keyed by name"
  type = map(object({
    vpc_cidr = string
    subnets = map(object({
      public_cidr  = string
      private_cidr = string
    }))
  }))

  default = {
    eks = {
      vpc_cidr = "10.0.0.0/16"
      subnets = {
        "us-east-1a" = { public_cidr = "10.0.0.0/22", private_cidr = "10.0.32.0/19" }
        "us-east-1b" = { public_cidr = "10.0.4.0/22", private_cidr = "10.0.64.0/19" }
      }
    }
  }
}
