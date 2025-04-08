# 관리 클러스터 control plane  보안그룹을 현재 클러스터의 control plane 보안그룹에 추가
resource "aws_security_group_rule" "allow_mgmt_to_pri" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_primary_security_group_id
  source_security_group_id = local.mgmt_eks_node_security_group_id
}