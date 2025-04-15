resource "aws_ecr_repository" "ecr-apiserver" {
  name = local.ecr_apiserver_repo_name
  tags = local.tags
}

resource "aws_ecr_repository" "ecr-frontweb" {
  name = local.ecr_frontweb_repo_name
  tags = local.tags
}

# terraform apply -target=aws_ecr_repository.ecr-apiserver -target=aws_ecr_repository.ecr-frontweb

data "aws_caller_identity" "current" {}

locals {
  ecr_apiserver_repo_name = "${var.phase}-${var.project}-ecr/apiserver"
  ecr_frontweb_repo_name  = "${var.phase}-${var.project}-ecr/frontweb"

  image_tag = "latest"

  ecr_apiserver_repo_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.ecr_apiserver_repo_name}:${local.image_tag}"
  ecr_frontweb_repo_url  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.ecr_frontweb_repo_name}:${local.image_tag}"
}