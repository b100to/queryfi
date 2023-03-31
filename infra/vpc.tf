module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = local.config.name
  cidr = local.config.cidr

  azs             = local.config.azs
  private_subnets = local.config.private_subnets
  public_subnets  = local.config.public_subnets

  enable_nat_gateway = local.config.enable_nat_gateway
  enable_vpn_gateway = local.config.enable_vpn_gateway

  tags = local.config.tags
}