set -e
set -x

terraform init \
	-backend-config "bucket=${TF_VAR_bucket_tf_state}" \
	-backend-config "region=${TF_VAR_region}" \
	-backend-config "key=${TF_VAR_project_name}/${TF_VAR_application}/${TF_VAR_environment}/terraform.tfstate" \
		terraform/ 
