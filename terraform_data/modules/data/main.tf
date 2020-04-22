resource "aws_rds_cluster" "default" {
  cluster_identifier      = "${var.project_name}-${var.environment}-aurora"
  engine                = "aurora"
  engine_mode           = "serverless"
  vpc_security_group_ids  = [aws_security_group.default_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.db_private_subnet.name
  database_name           = var.db_name
  master_username         = var.db_user
  master_password         = var.db_password
  apply_immediately       = true
  skip_final_snapshot     = true

  lifecycle {
    ignore_changes = [master_password]
    create_before_destroy = true
  }

}

#fetch subnet info from subnet id
locals {
  private_subnet_ids = toset(split(",", var.subnets))
}

data "aws_subnet" "private" {
  for_each = local.private_subnet_ids
  id       = each.value
}

resource "aws_security_group" "default_sg" {
  name   = "${var.project_name}-${var.environment}-rds-sg"
  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    cidr_blocks = [for s in data.aws_subnet.private : s.cidr_block]
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "Private connection"
  }
}

resource "aws_db_subnet_group" "db_private_subnet" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = split(",", var.subnets)

  tags = {
    Name = "${var.project_name}-db-subnet"
  }
}


resource "aws_ssm_parameter" "db_host" {
  name        = "/${var.environment}/database/host"
  description = "DB host endpoint with port"
  type        = "String"
  value = "${aws_rds_cluster.default.endpoint}:${aws_rds_cluster.default.port}"
  tags = {
    Environment = "${var.environment}"
    Project = "${var.project_name}"
  }
  
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/${var.environment}/database/name"
  description = "DB name"
  type        = "String"
  value = aws_rds_cluster.default.database_name
  tags = {
    Environment = "${var.environment}"
    Project = "${var.project_name}"
  }
  
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}