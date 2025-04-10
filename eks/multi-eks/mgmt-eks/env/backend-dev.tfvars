# terraform backend s3 config
# backend-dev.tfvars
profile        = ""
region         = "ap-northeast-2"
bucket         = "cjo-mgmt-s3-terraform-state"
dynamodb_table = "cjo-mgmt-ddb-terraform-state"
key            = "multi-eks/dev/terraform.tfstate"