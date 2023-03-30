module "iam" {
  source   = "./modules/iam"
  app_name = local.config.name
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = join("-", [local.config.name, local.config.tags.Environment])
  cidr = local.config.cidr

  azs             = local.config.azs
  private_subnets = local.config.private_subnets
  public_subnets  = local.config.public_subnets

  enable_nat_gateway = local.config.enable_nat_gateway
  enable_vpn_gateway = local.config.enable_vpn_gateway

  tags = local.config.tags
}

#module "internal_alb_security_group" {
#  source        = "./modules/security-group"
#  name          = "${lower(local.config.name)}-internal-alb-sg"
#  description   = "${lower(local.config.name)}-internal-alb-sg"
#  vpc_id        = module.vpc.vpc_id
#  ingress_rules = local.config.internal_alb_config.ingress_rules
#  egress_rules  = local.config.internal_alb_config.egress_rules
#}

module "public_alb_security_group" {
  source        = "./modules/security-group"
  name          = "${lower(local.config.name)}-public-alb-sg"
  description   = "${lower(local.config.name)}-public-alb-sg"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = local.config.public_alb_config.ingress_rules
  egress_rules  = local.config.public_alb_config.egress_rules
}
#
#module "internal-alb" {
#  source            = "./modules/alb"
#  name              = "${lower(local.config.name)}-internal-alb"
#  subnets           = module.vpc.private_subnets
#  vpc_id            = module.vpc.vpc_id
#  target_groups     = {for service, config in local.config.microservice_config : service => config.alb_target_group if config.is_public}
#  internal          = true
#  listener_port     = 80
#  listener_protocol = "HTTP"
#  listeners         = local.config.internal_alb_config.listeners
#  security_groups   = [module.internal_alb_security_group.security_group_id]
#}
#
#module "public-alb" {
#  source            = "./modules/alb"
#  name              = "${lower(local.config.name)}-public-alb"
#  subnets           = module.vpc.public_subnets
#  vpc_id            = module.vpc.vpc_id
#  target_groups     = {for service, config in local.config.microservice_config : service => config.alb_target_group if config.is_public}
#  internal          = false
#  listener_port     = 80
#  listener_protocol = "HTTP"
#  listeners         = local.config.public_alb_config.listeners
#  security_groups   = [module.public_alb_security_group.security_group_id]
#}
#
#module "route53_private_zone" {
#  source            = "./modules/route53"
#  internal_url_name = local.config.internal_url_name
#  alb               = module.internal-alb.internal_alb
#  vpc_id            = module.vpc.vpc_id
#}
#
module "ecr" {
  source           = "./modules/ecr"
  app_name         = local.config.name
  ecr_repositories = local.config.app_services
}

#module "ecs" {
#  source                      = "./modules/ecs"
#  app_name                    = local.config.name
#  app_services                = local.config.app_services
#  account                     = local.config.account
#  region                      = local.config.region
#  service_config              = local.config.microservice_config
#  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
#  vpc_id                      = module.vpc.vpc_id
#  private_subnets             = module.vpc.private_subnets
#  public_subnets              = module.vpc.public_subnets
#  public_alb_security_group   = module.public_alb_security_group
#  internal_alb_security_group = module.internal_alb_security_group
#  internal_alb_target_groups  = module.internal-alb.target_groups
#  public_alb_target_groups    = module.public-alb.target_groups
#}
