variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16" # Use a /16 VPC to accommodate the planned public and private subnets
}

# keyed by AZ name, so adding or removing an AZ never shifts the other subnets
variable "subnets" {
  description = "Public and private subnet CIDR per AZ"
  type = map(object({
    public_cidr  = string
    private_cidr = string
  }))
}
