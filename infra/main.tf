data "aws_caller_identity" "current" {}

module "ecr" {
  source  = "cloudposse/ecr/aws"
  version = "0.35.0"
  name    = local.config.name
  tags    = local.config.tags
}

module "ecr_db" {
  source  = "cloudposse/ecr/aws"
  version = "0.35.0"
  name    = local.config.container_postgresql_name
  tags    = local.config.tags
}


resource "aws_ecs_cluster" "default" {
  name = local.config.name
  tags = local.config.tags
}

module "container_definition_app" {
  source                       = "cloudposse/ecs-container-definition/aws"
  version                      = "0.58.2"
  container_name               = local.config.container_app_name
  container_image              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.config.region}.amazonaws.com/${local.config.container_app_image}"
  container_memory             = local.config.container_app_memory
  container_memory_reservation = local.config.container_app_memory_reservation
  container_cpu                = local.config.container_app_cpu
  essential                    = local.config.container_app_essential
  port_mappings                = local.config.container_app_port_mappings
  command                      = local.config.container_app_command
}

module "container_definition_postgresql" {
  source                       = "cloudposse/ecs-container-definition/aws"
  version                      = "0.58.2"
  container_name               = local.config.container_postgresql_name
  container_image              = local.config.container_postgresql_image
  container_memory             = local.config.container_postgresql_memory
  container_memory_reservation = local.config.container_postgresql_memory_reservation
  container_cpu                = local.config.container_postgresql_cpu
  essential                    = local.config.container_postgresql_essential
  environment                  = local.config.container_postgresql_environment
  port_mappings                = local.config.container_postgresql_port_mappings

}

module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.config.name}-alb-logs"
  acl    = local.config.acl

  # Allow deletion of non-empty bucket
  force_destroy = local.config.force_destroy
  attach_elb_log_delivery_policy = local.config.attach_elb_log_delivery_policy
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${local.config.name}-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.private_subnets
  security_groups    = [
    module.app_security_group.id,
    module.db_security_group.id
  ]

  access_logs = {
    bucket = "${local.config.name}-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = local.config.tags
  depends_on = [
    module.vpc,
    module.s3_bucket_for_logs
  ]
}

module "ecs_alb_service_task" {
  source             = "cloudposse/ecs-alb-service-task/aws"
  version            = "0.68.0"
  name               = "${local.config.name}-${local.config.env}"
  alb_security_group = module.vpc.default_security_group_id
  container_definition_json = jsonencode([
    module.container_definition_app.json_map_object,
    module.container_definition_postgresql.json_map_object
  ])
  ecs_cluster_arn                = aws_ecs_cluster.default.arn
  launch_type                    = local.config.ecs_launch_type
  vpc_id                         = module.vpc.vpc_id
  security_group_enabled =  local.config.security_group_enabled
  security_group_ids             = [
    module.app_security_group.id,
    module.db_security_group.id
  ]
  subnet_ids                     = module.vpc.private_subnets
  ignore_changes_task_definition = local.config.ignore_changes_task_definition
  network_mode                   = local.config.network_mode
  propagate_tags                 = local.config.propagate_tags
  desired_count                  = local.config.desired_count
  task_memory                    = local.config.task_memory
  task_cpu                       = local.config.task_cpu
  exec_enabled                   = local.config.exec_enabled
  force_new_deployment           = local.config.force_new_deployment
#  ecs_load_balancers             = [{
#    container_name   = local.config.container_app_name
#    container_port   = local.config.container_port
#    elb_name         = ""
#    target_group_arn = module.alb.security_group_arn
#  }]
  tags                           = local.config.tags
  depends_on = [
    module.vpc,
    aws_ecs_cluster.default,
    module.container_definition_app,
    module.container_definition_postgresql,
    module.app_security_group,
    module.db_security_group,
    module.alb
  ]
}
