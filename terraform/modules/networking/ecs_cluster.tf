resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-ecs-cluster"
  capacity_providers = ["FARGATE"]
}