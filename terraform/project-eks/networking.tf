# VPC, subnets, NAT and security groups, one set per entry in var.networks (see ../modules/networking)
module "networking" {
  source   = "../modules/networking"
  for_each = var.networks

  # the module uses the primary region, passed in explicitly
  providers = {
    aws = aws.primary
  }

  name_prefix  = "${local.name_prefix}-${each.key}" # jarvis-prod-eks
  cluster_name = local.name_prefix                  # jarvis-prod, follows project + environment
  vpc_cidr     = each.value.vpc_cidr
  subnets      = each.value.subnets
}
