#Create services for app services
resource "aws_ecs_service" "private_service" {
  for_each = var.service_config

  name            = "${each.value.name}-Service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition[each.key].arn
  launch_type     = "FARGATE"
  desired_count   = each.value.desired_count

  network_configuration {
    subnets          = each.value.is_public ==true ? var.public_subnets : var.private_subnets
    assign_public_ip = each.value.is_public ==true ? true : false
    security_groups  = [
      each.value.is_public == true ? aws_security_group.webapp_security_group.id : aws_security_group.service_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = each.value.is_public==true ? var.public_alb_target_groups[each.key].arn : var.internal_alb_target_groups[each.key].arn
    container_name   = each.value.name
    container_port   = each.value.container_port
  }
}

resource "aws_security_group" "service_security_group" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.internal_alb_security_group.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webapp_security_group" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.public_alb_security_group.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}