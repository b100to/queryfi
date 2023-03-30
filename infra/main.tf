module "iam" {
  source   = "./modules/iam"
  app_name = var.app_name
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


module "internal_alb_security_group" {
  source        = "./modules/security-group"
  name          = "${lower(var.app_name)}-internal-alb-sg"
  description   = "${lower(var.app_name)}-internal-alb-sg"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.internal_alb_config.ingress_rules
  egress_rules  = var.internal_alb_config.egress_rules
}

module "public_alb_security_group" {
  source        = "./modules/security-group"
  name          = "${lower(var.app_name)}-public-alb-sg"
  description   = "${lower(var.app_name)}-public-alb-sg"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.public_alb_config.ingress_rules
  egress_rules  = var.public_alb_config.egress_rules
}

module "internal-alb" {
  source            = "./modules/alb"
  name              = "${lower(var.app_name)}-internal-alb"
  subnets           = module.vpc.private_subnets
  vpc_id            = module.vpc.vpc_id
  target_groups     = local.internal_alb_target_groups
  internal          = true
  listener_port     = 80
  listener_protocol = "HTTP"
  listeners         = var.internal_alb_config.listeners
  security_groups   = [module.internal_alb_security_group.security_group_id]
}

module "public-alb" {
  source            = "./modules/alb"
  name              = "${lower(var.app_name)}-public-alb"
  subnets           = module.vpc.public_subnets
  vpc_id            = module.vpc.vpc_id
  target_groups     = local.public_alb_target_groups
  internal          = false
  listener_port     = 80
  listener_protocol = "HTTP"
  listeners         = var.public_alb_config.listeners
  security_groups   = [module.public_alb_security_group.security_group_id]
}

module "route53_private_zone" {
  source            = "./modules/route53"
  internal_url_name = var.internal_url_name
  alb               = module.internal-alb.internal_alb
  vpc_id            = module.vpc.vpc_id
}

module "ecr" {
  source           = "./modules/ecr"
  app_name         = var.app_name
  ecr_repositories = var.app_services
}

module "ecs" {
  source                      = "./modules/ecs"
  app_name                    = var.app_name
  app_services                = var.app_services
  account                     = var.account
  region                      = var.region
  service_config              = var.microservice_config
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  public_subnets              = module.vpc.public_subnets
  public_alb_security_group   = module.public_alb_security_group
  internal_alb_security_group = module.internal_alb_security_group
  internal_alb_target_groups  = module.internal-alb.target_groups
  public_alb_target_groups    = module.public-alb.target_groups
}
