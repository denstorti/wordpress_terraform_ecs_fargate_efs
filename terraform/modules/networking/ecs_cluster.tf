resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-ecs-cluster"
  capacity_providers = ["FARGATE"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
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

  load_balancer {
    target_group_arn = aws_lb_target_group.wordpress.arn
    container_name   = "wordpress"
    container_port   = 80
  }

  depends_on = [
    aws_lb_target_group.wordpress,
  ]
}

resource "aws_lb_target_group" "wordpress" {
  name     = "${var.project_name}-${var.environment}-wordpress-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id

  health_check {
     enabled             = true
     healthy_threshold   = 5
     interval            = 30
     matcher             = "200-399"
     path                = "/"
     port                = "traffic-port"
     protocol            = "HTTP"
     timeout             = 5
     unhealthy_threshold = 2
  }
}

resource "aws_lb" "wordpress" {
  name               = "${var.project_name}-${var.environment}-wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_default_security_group.allow_public_tcp80.id]
  subnets            = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]

  enable_deletion_protection = true

  tags = {
    Environment = var.environment
    Project = var.project_name
  }
}

resource "aws_lb_listener" "wordpress" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}

resource "aws_ecs_task_definition" "wordpress" {
  family                = "${var.project_name}-${var.environment}-wordpress"
  container_definitions = file("task-definitions/wordpress.json")
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  task_role_arn = aws_iam_role.ecs_tasks_execution_role.arn
  cpu   =  256
  memory = 512
  execution_role_arn = aws_iam_role.ecs_tasks_execution_role.arn

  volume {
    name = "efs-storage-wordpress"

    efs_volume_configuration {
      file_system_id  = aws_efs_file_system.main.id
      root_directory = "/"
    }
  }
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
    Environment = var.environment
    Project = var.project_name
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

resource "aws_iam_role_policy" "ssm_read" {
  name = "SSMReadPermission"
  role = aws_iam_role.ecs_tasks_execution_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
            "ssm:DescribeParameters",
            "ssm:GetParameters",
            "ssm:GetParameter"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}