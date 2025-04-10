variable "cluster_name" {
  description = "k3d cluster name"
  type        = string
  default     = "local-cluster"
}

variable "cluster_port" {
  description = "k3d cluster API port"
  type        = number
  default     = 6443
}

variable "node_count" {
  description = "k3d cluster node count"
  type        = number
  default     = 2
}

variable "port_args" {
  description = "k3d cluster port arguments"
  type        = string
  default     = "--port 8080:80"
}