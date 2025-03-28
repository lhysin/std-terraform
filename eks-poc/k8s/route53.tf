# 이미 등록된 호스팅 존 정보 가져오기
data "aws_route53_zone" "target_hosted_zone" {
  name = "${var.route53_domain_name}." # 대상 도메인 (마침표로 끝나는 FQDN 형식)
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = "kube-system"
  }
}

# resource "aws_route53_record" "echo_cname" {
#   zone_id = data.aws_route53_zone.target_hosted_zone.zone_id
#   name    = "eks-test-echo.${var.route53_domain_name}"
#   type    = "CNAME"
#   ttl     = 60
#   records = [data.kubernetes_service.ingress_nginx_service.status[0].load_balancer[0].ingress[0].hostname]
#   depends_on = [
#     data.kubernetes_service.ingress_nginx_service]
# }

resource "aws_route53_record" "bff_cname" {
  zone_id = data.aws_route53_zone.target_hosted_zone.zone_id
  name    = "eks-test-bff.${var.route53_domain_name}"
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_service.ingress_nginx_service.status[0].load_balancer[0].ingress[0].hostname]
  depends_on = [
    data.kubernetes_service.ingress_nginx_service]
}

resource "aws_route53_record" "argocd_cname" {
  zone_id = data.aws_route53_zone.target_hosted_zone.zone_id
  name    = "eks-test-argocd.${var.route53_domain_name}"
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_service.ingress_nginx_service.status[0].load_balancer[0].ingress[0].hostname]
  depends_on = [
    data.kubernetes_service.ingress_nginx_service]
}

resource "aws_route53_record" "k8s_dashboard_cname" {
  zone_id = data.aws_route53_zone.target_hosted_zone.zone_id
  name    = "eks-test-dashboard.${var.route53_domain_name}"
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_service.ingress_nginx_service.status[0].load_balancer[0].ingress[0].hostname]
  depends_on = [
    data.kubernetes_service.ingress_nginx_service]
}