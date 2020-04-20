# wordpress_terraform_ecs_fargate_efs
Wordpress running on AWS ECS, Fargate and EFS. Infra as Code in Terraform.


## Prerequisites
- AWS_PROFILE set with valid credentials with permissions for:
  - Manage S3 buckets
  - Manage resources in this solution (ECS, ECR, VPC, S3, EFS, etc)

## Run it

- Set your bucket name in `TERRAFORM_STATE_BUCKET`
- Set your ECR url `ECR_REPO`
- Set it up: `make prepare`
- Deploy: `make deploy`

## Clean it up
- `make undeploy`
- `make clean`