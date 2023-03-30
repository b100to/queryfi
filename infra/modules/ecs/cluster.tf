resource "aws_ecs_cluster" "ecs_cluster" {
  name = lower("${var.app_name}-cluster")
}