set -e
set -x

TOKEN=$(aws ecr get-login-password --region ap-southeast-2)
docker login --username AWS --password ${TOKEN} ${ECR_REPO}/${AWS_IMAGE}
docker tag ${AWS_IMAGE}:${GIT_SHA} ${ECR_REPO}/${AWS_IMAGE}:${GIT_SHA}
docker push ${ECR_REPO}/${AWS_IMAGE}:${GIT_SHA}

aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${ECR_REPO}/${TERRAFORM_IMAGE}
docker tag ${TERRAFORM_IMAGE}:${GIT_SHA} ${ECR_REPO}/${TERRAFORM_IMAGE}:${GIT_SHA}
docker push ${ECR_REPO}/${TERRAFORM_IMAGE}:${GIT_SHA}