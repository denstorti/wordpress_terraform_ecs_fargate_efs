resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "aws_ssm_parameter" "db_user" {
  name        = "/${var.environment}/database/user"
  description = "DB user"
  type  = "String"
  value = "temp"
  overwrite = true
}

resource "aws_ssm_parameter" "db_pass" {
  name        = "/${var.environment}/database/password"
  description = "DB password"
  type        = "SecureString"
  value = random_password.password.result
  tags = {
    environment = "${var.environment}"
  }
  overwrite = true
}