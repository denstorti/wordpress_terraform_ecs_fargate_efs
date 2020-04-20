set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir ${DIR}/output || true

terraform plan -destroy terraform_data/
terraform destroy -auto-approve terraform_data/
