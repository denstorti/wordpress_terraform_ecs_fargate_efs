set -e
set -x

terraform init \
	-backend-config "bucket=${TF_VAR_bucket_tf_state}" \
	-backend-config "region=${TF_VAR_region}" \
	-backend-config "key=${TF_VAR_project_name}/terraform.tfstate" \
	-backend-config "workspace_key_prefix=${TF_VAR_environment}" \
		terraform/ 

terraform init \
	-backend-config "bucket=${TF_VAR_bucket_tf_state}" \
	-backend-config "region=${TF_VAR_region}" \
	-backend-config "key=${TF_VAR_project_name}/terraform.tfstate" \
	-backend-config "workspace_key_prefix=${TF_VAR_environment}" \
		terraform_data/ 

terraform workspace new network terraform/ || true
terraform workspace new data terraform_data/ || true