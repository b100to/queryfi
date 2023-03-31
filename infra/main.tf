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

module "sg_app" {
  source     = "cloudposse/security-group/aws"
  version    = "2.0.1"
  attributes = ["primary"]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key         = "HTTP"
      type        = "ingress"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = []
      self        = true
    }
  ]

  vpc_id = module.vpc.vpc_id
  tags   = local.config.tags
}

module "ecr" {
  source = "cloudposse/ecr/aws"
  version = "0.35.0"
  name                   = local.config.name
  tags = local.config.tags
}

resource "aws_ecs_cluster" "default" {
  name = local.config.name
  tags = local.config.tags
}

module "container_definition" {
  source                       = "cloudposse/ecs-container-definition/aws"
  version                      = "0.58.2"
  container_name               = local.config.container_name
  container_image              = local.config.container_image
  container_memory             = local.config.container_memory
  container_memory_reservation = local.config.container_memory_reservation
  container_cpu                = local.config.container_cpu
  essential                    = local.config.container_essential
  environment                  = local.config.container_environment
  port_mappings                = local.config.container_port_mappings
}

module "ecs_alb_service_task" {
  source             = "cloudposse/ecs-alb-service-task/aws"
  version            = "0.68.0"
  name               = local.config.name
  alb_security_group = module.vpc.default_security_group_id
  container_definition_json = jsonencode([
    module.container_definition.json_map_object,
  ])
  ecs_cluster_arn                = aws_ecs_cluster.default.arn
  launch_type                    = local.config.ecs_launch_type
  vpc_id                         = module.vpc.vpc_id
  security_group_ids             = [module.vpc.default_security_group_id]
  subnet_ids                     = module.vpc.public_subnets
  ignore_changes_task_definition = local.config.ignore_changes_task_definition
  network_mode                   = local.config.network_mode
  assign_public_ip               = local.config.assign_public_ip
  propagate_tags                 = local.config.propagate_tags
  desired_count                  = local.config.desired_count
  task_memory                    = local.config.task_memory
  task_cpu                       = local.config.task_cpu
  tags                           = local.config.tags
  depends_on = [
    module.vpc,
    aws_ecs_cluster.default,
    module.container_definition
  ]
}