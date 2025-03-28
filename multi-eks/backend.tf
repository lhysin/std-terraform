# https://developer.hashicorp.com/terraform/language/backend
# terraform backend 를 통해 상태관리를 s3 원격지에서 수행한다.
# s3 는 terraform.tfstate 파일을 저장
# ddb 는 상태 수정시 Lock 을 걸어 동시성을 보장.
# ./env/backend-*.tfvars
# terraform init -backend-config ./env/backend-std.tfvars
terraform {
  backend "s3" {}
