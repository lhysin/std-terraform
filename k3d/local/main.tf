module "k3d" {
  source = "../modules/k3d"
  port_args = "--port 8080:80@loadbalancer:0 --port 8443:443@loadbalancer:0"
}

provider "kubernetes" {
  host = module.k3d.kube_api_host
  cluster_ca_certificate = module.k3d.cluster_ca_certificate
  client_certificate = module.k3d.client_certificate
  client_key = module.k3d.client_key
}

provider "helm" {
  kubernetes {
    host = module.k3d.kube_api_host
    cluster_ca_certificate = module.k3d.cluster_ca_certificate
    client_certificate = module.k3d.client_certificate
    client_key = module.k3d.client_key
  }
}