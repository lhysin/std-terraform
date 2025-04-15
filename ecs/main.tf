provider "aws" {
  region  = var.region
  profile = var.profile
}

locals {
  tags = {
    phase   = var.phase
    author  = "lhysin"
    owner   = "lhysin"
    team    = "cjenm-arch"
    service = "study-ecs"
  }
}