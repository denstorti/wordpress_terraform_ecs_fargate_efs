resource "aws_efs_file_system" "main" {
  creation_token = "${var.project_name}-${var.environment}-efs-${var.application}"

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  tags = {
    Environment = var.environment
    Project = var.project_name
    Name = "${var.project_name}-${var.environment}-${var.application}"
  }
}

locals {
  subnets = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]
  subnets_count = length(local.subnets)
}

resource "aws_efs_mount_target" "main" {
  count = local.subnets_count
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = local.subnets[count.index]
	security_groups = [aws_security_group.efs.id]
}


resource "aws_security_group" "efs" {
	name        = "allow_nfs"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "NFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "${var.project_name}-nfs-sg"
    Environment = var.environment
    Project = var.project_name
  }
}