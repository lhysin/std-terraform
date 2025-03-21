# data "http" "iam_policy" {
#   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.0/docs/install/iam_policy.json"
# }
#
# resource "aws_iam_role_policy" "controller" {
#   name_prefix = "AWSLoadBalancerControllerIAMPolicy"
#   policy      = data.http.iam_policy.body
#   role        = module.lb_controller_role.iam_role_name
# }