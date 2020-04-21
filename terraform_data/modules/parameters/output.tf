output "db_user" {
  value = aws_ssm_parameter.db_user.value
}

output "db_password" {
	value = aws_ssm_parameter.db_pass.value
}
