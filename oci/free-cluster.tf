provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  private_key  = var.private_key
  fingerprint  = var.fingerprint
  region       = var.region
}

module "free-tier-kubernetes" {
  source  = "robinlieb/free-tier-kubernetes/oci"
  version = "0.2.0"

  tenancy_ocid    = var.tenancy_ocid
  user_ocid       = var.user_ocid
  private_key     = var.private_key
  fingerprint     = var.fingerprint
  region          = var.region
  ssh_public_key  = var.ssh_public_key
  ssh_private_key = var.ssh_private_key
}
