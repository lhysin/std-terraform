resource "null_resource" "create_k3d_cluster" {
  provisioner "local-exec" {
    command = "k3d cluster create ${var.cluster_name} --agents ${var.node_count} --api-port ${var.cluster_port} ${var.port_args}"
  }
}

resource "null_resource" "destroy_k3d_cluster" {
  triggers = {
    cluster_name = var.cluster_name
  }
  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete ${self.triggers.cluster_name}"
  }
}

# 인증 정보 조회
data "external" "kube_config" {
  program = [
    "bash", "-c",
    <<-EOT
      kubeconfig=$(k3d kubeconfig get ${var.cluster_name})

      certificate_authority_data=$(echo "$kubeconfig" | grep 'certificate-authority-data' | awk '{print $2}')
      client_certificate_data=$(echo "$kubeconfig" | grep 'client-certificate-data' | awk '{print $2}')
      client_key_data=$(echo "$kubeconfig" | grep 'client-key-data' | awk '{print $2}')

      jq -n --arg ca "$certificate_authority_data" --arg cert "$client_certificate_data" --arg key "$client_key_data" \
        '{certificate_authority_data: $ca, client_certificate_data: $cert, client_key_data: $key}'
    EOT
  ]

  depends_on = [
    null_resource.create_k3d_cluster
  ]
}