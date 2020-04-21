

module "parameters" {
  source        = "./modules/parameters"
  project_name  = var.project_name
  environment = var.environment
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.environment}/network/vpc_id"
}

data "aws_ssm_parameter" "private_subnets" {
  name = "/${var.environment}/network/subnets/private"
}

# module "data" {
#   source   = "./modules/data"
#   db_name  = var.db_name
#   db_user  = data.aws_ssm_parameter.db_user.value
#   db_password  = data.aws_ssm_parameter.db_password.value
#   subnets  = data.aws_ssm_parameter.private_subnets.value
#   vpc_id  = data.aws_ssm_parameter.vpc_id.value
# }

