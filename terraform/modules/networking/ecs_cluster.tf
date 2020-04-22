resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-ecs-cluster"
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_service" "wordpress" {
  name            = "wordpress"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  platform_version = "1.4.0"
  network_configuration {
    subnets       = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]
    security_groups  = [aws_default_security_group.allow_public_tcp80.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "wordpress" {
  family                = "${var.project_name}-${var.environment}-wordpress"
  container_definitions = file("task-definitions/wordpress.json")
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu   =  256
  memory = 512
  execution_role_arn = aws_iam_role.ecs_tasks_execution_role.arn
}

resource "aws_default_security_group" "allow_public_tcp80" {
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "${var.project_name}-${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}