set -e
set -x

SHA=$(${GIT_SHA})

TERRAFORM_REPO=$(aws ssm get-parameter --name /${ENVIRONMENT}/ecr/${TERRAFORM_IMAGE} --query Parameter.Value | tr -d "\"")
AWS_REPO=$(aws ssm get-parameter --name /${ENVIRONMENT}/ecr/${AWS_IMAGE} --query Parameter.Value | tr -d "\"")
WORDPRESS_REPO=$(aws ssm get-parameter --name /${ENVIRONMENT}/ecr/${WORDPRESS_IMAGE} --query Parameter.Value | tr -d "\"")

aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${AWS_REPO}
docker tag ${AWS_IMAGE}:${SHA} ${AWS_REPO}:${SHA}
docker push ${AWS_REPO}:${SHA}

aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${TERRAFORM_REPO}
docker tag ${TERRAFORM_IMAGE}:${SHA} ${TERRAFORM_REPO}:${SHA}
docker push ${TERRAFORM_REPO}:${SHA}

aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${WORDPRESS_REPO}
docker tag ${WORDPRESS_IMAGE}:${SHA} ${WORDPRESS_REPO}:${SHA}
docker push ${WORDPRESS_REPO}:${SHA}