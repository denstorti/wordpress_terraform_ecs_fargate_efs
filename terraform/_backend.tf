terraform {
  required_version = ">= 0.12.24"
  backend "s3" {
    # bucket = "${var.bucket_tf_state}"
    # key    = "${var.project_name}/${var.application}/${var.environment}/terraform.tfstate"
    # region = "${var.region}"
  }
}