# terraform backend s3 config
# backend-prd.tfvars
region = "ap-northeast-2"
bucket = "cjo-mgmt-s3-terraform-state"
dynamodb_table = "cjo-mgmt-ddb-terraform-state"
key = "study-eks/prd/terraform.tfstate"