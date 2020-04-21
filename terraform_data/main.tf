

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

module "data" {
  source   = "./modules/data"

  project_name = var.project_name
  environment = var.environment
  db_name  = var.db_name
  db_user  = module.parameters.db_user
  db_password  = module.parameters.db_password
  subnets  = data.aws_ssm_parameter.private_subnets.value
  vpc_id  = data.aws_ssm_parameter.vpc_id.value
}

