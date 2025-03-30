# std-terraform

## reference

[Kubernetes-Playlist](https://github.com/ravindrasinghh/Kubernetes-Playlist)

[terraform-eks](https://spacelift.io/blog/terraform-eks)

### terraform 설치 방법
```bash
# terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform -help

# aws cli
brew install awscli
aws --version

# python for terraform-aws-modules/lambda/aws
# Requires Python 3.6 or newer.
brew install python
```

### terraform cli
```bash

cd terraform
# 의존성 설치
terraform init

# terraform 코드 포멧팅
terraform fmt

# terraform 코드 유효성 검증
terraform validate

# 인프라 배포
terraform apply

# 인프라 상태를 출력
terraform show

# 인프라 적용 해제
terraform destroy

# 자동승인
terraform apply -auto-approve
terraform destory -auto-approve
```
람다만 수정하고 배포가능.

### Terraform Backend 전략
```bash
# 테라폼의 상태관리를 s3와 dynamoDB를 통해 진행한다.

# study
terraform init -backend-config ./env/backend-std.tfvars

terraform init \
  -backend-config="bucket=cjo-std-s3-terraform-state" \
  -backend-config="key=multi-eks/shared/std/terraform.tfstate" \
  -backend-config="region=ap-northeast-2" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=cjo-std-ddb-terraform-state"

# dev
terraform init -backend-config ./env/backend-dev.tfvars

# prd
terraform init -backend-config ./env/backend-prd.tfvars

# terraform 초기화 재설정
terraform init -reconfigure -backend-config ./env/backend-std.tfvars

# 활성화된 backend 확인
cat .terraform/terraform.tfstate | grep '"bucket"'
```

### 프로필 전략
```bash
# export AWS_PROFILE=cjenm-itarch
# study
terraform apply -var-file="./env/std.tfvars"


# export AWS_PROFILE=iteminfo
# dev
terraform apply -var-file="./env/dev.tfvars"


# export AWS_PROFILE=iteminfo
# prd
terraform apply -var-file="./env/prd.tfvars"

# 활성화된 변수 확인
terraform state pull | grep "phase"
```