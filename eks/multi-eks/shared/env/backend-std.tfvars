# terraform backend s3 config
# backend-std.tfvars
profile        = "cjenm-itarch"
region         = "ap-northeast-2"
bucket         = "cjo-std-s3-terraform-state"
dynamodb_table = "cjo-std-ddb-terraform-state"
key            = "multi-eks/shared/std/terraform.tfstate"