# terraform backend s3 config
# backend-std.tfvars
region = "ap-northeast-2"
bucket = "cjo-std-s3-terraform-state"
dynamodb_table = "cjo-std-ddb-terraform-state"
key = "k8s/std/terraform.tfstate"