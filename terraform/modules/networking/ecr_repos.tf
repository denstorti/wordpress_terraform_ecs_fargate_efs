locals {
  names = ["aws_3m", "terraform_3m", "wordpress"]
}

resource "aws_ecr_repository" "repos" {
  count = length(local.names)

  name                 = local.names[count.index]
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-${local.names[count.index]}"
  }
}

resource "aws_ssm_parameter" "repo_endpoints" {
  count = length(local.names)
  name        = "/${var.environment}/ecr/${local.names[count.index]}"
  description = "ECR repo for ${local.names[count.index]}"
  type  = "String"
  value = aws_ecr_repository.repos[count.index].repository_url
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
