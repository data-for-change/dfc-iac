locals {
  k8s_main_ingress_target_names = [
    "argocd",
    "argocd-grpc",
    "grafana",
    "vault",
  ]
}

data "cloudflare_zone" "infrastructure_root_domain" {
  name = var.infrastructure_root_domain
}

data "aws_lb" "k8s_main_ingress" {
  tags = {
    "kubernetes.io/service-name" = "ingress-nginx/ingress-nginx-controller"
    "kubernetes.io/cluster/main" = "owned"
  }
}

resource "cloudflare_record" "k8s_main_ingress" {
  zone_id = data.cloudflare_zone.infrastructure_root_domain.id
  name    = "k8s-main-ingress"
  value   = data.aws_lb.k8s_main_ingress.dns_name
  type    = "CNAME"
}

resource "cloudflare_record" "k8s_main_ingress_target" {
  for_each = toset(local.k8s_main_ingress_target_names)
  zone_id = data.cloudflare_zone.infrastructure_root_domain.id
  name    = each.key
  value   = "${cloudflare_record.k8s_main_ingress.name}.${data.cloudflare_zone.infrastructure_root_domain.name}"
  type    = "CNAME"
}
