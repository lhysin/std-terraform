# output "all_availability_domains" {
#   value = module.free-tier-kubernetes.all_availability_domains
#   description = "All availability domains."
# }
#
# output "available_images" {
#   value = module.free-tier-kubernetes.available_images
#   description = "Available images."
# }
#
# output "client_certificate" {
#   value = module.free-tier-kubernetes.client_certificate
#   description = "Kubernetes Client Certificate"
# }
#
# output "client_key" {
#   value = module.free-tier-kubernetes.client_key
#   description = "Kubernetes Client Key"
#   sensitive = true
# }
#
# output "cluster_ca_certificate" {
#   value = module.free-tier-kubernetes.cluster_ca_certificate
#   description = "Kubernetes Cluster CA Certificate"
# }
#
# output "compartment_id" {
#   value = module.free-tier-kubernetes.compartment_id
#   description = "ID of the compartment."
# }
#
# output "compartment_name" {
#   value = module.free-tier-kubernetes.compartment_name
#   description = "Name of the compartment."
# }
#
# output "instance_OCPUs" {
#   value = module.free-tier-kubernetes.instance_OCPUs
#   description = "CPUs of the instances."
# }
#
# output "instance_memory_in_GBs" {
#   value = module.free-tier-kubernetes.instance_memory_in_GBs
#   description = "Memory in GB of the instances."
# }
#
# output "instance_name" {
#   value = module.free-tier-kubernetes.instance_name
#   description = "Names of the instances."
# }
#
# output "instance_ocid" {
#   value = module.free-tier-kubernetes.instance_ocid
#   description = "OCID of the instances."
# }
#
# output "instance_region" {
#   value = module.free-tier-kubernetes.instance_region
#   description = "Region of the instances."
# }
#
# output "instance_shape" {
#   value = module.free-tier-kubernetes.instance_shape
#   description = "Shape of the instances."
# }
#
# output "instance_state" {
#   value = module.free-tier-kubernetes.instance_state
#   description = "State of the instances."
# }
#
output "kubeconfig" {
  value = module.free-tier-kubernetes.kubeconfig
  description = "Kubeconfig to access the cluster"
  sensitive = true
}

output "kubeconfig_commands" {
  value = module.free-tier-kubernetes.kubeconfig_commands
  description = "Kubeconfig commands to apply to local kubeconfig"
  sensitive = true
}
#
# output "public_ip_for_compute_instance" {
#   value = module.free-tier-kubernetes.public_ip_for_compute_instance
#   description = "Public IPs of the instances."
# }
#
# output "time_created" {
#   value = module.free-tier-kubernetes.time_created
#   description = "Creation time of the instances"
# }
#
# output "vcn_id_route_id" {
#   value = module.free-tier-kubernetes.vcn_id_route_id
#   description = "ID of the route."
# }
#
# output "vcn_nat_gateway_id" {
#   value = module.free-tier-kubernetes.vcn_nat_gateway_id
#   description = "ID of the NAT gateway."
# }
#
# output "vcn_nat_route_id" {
#   value = module.free-tier-kubernetes.vcn_nat_route_id
#   description = "ID of the NAT route."
# }
#
# output "vcp_id" {
#   value = module.free-tier-kubernetes.vcp_id
#   description = "ID of the VCN."
# }
