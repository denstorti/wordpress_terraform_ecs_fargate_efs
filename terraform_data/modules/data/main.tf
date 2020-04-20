data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "${var.db_name}-aurora"
  engine                = "aurora"
  engine_mode           = "serverless"
  # vpc_id                = var.vpc_id
  availability_zones      = data.aws_availability_zones.available.all_availability_zones
  database_name           = var.db_name
  master_username         = var.db_user
  master_password         = var.db_password
}