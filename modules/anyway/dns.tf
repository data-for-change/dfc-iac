locals {
  k8s_dns_record = {type="CNAME", records=[var.dfc_k8s_main_ingress_hostname]}
  anyway_co_il_dns_records = {
    "airflow-data" = local.k8s_dns_record
    "airflow" = local.k8s_dns_record
    "dev-airflow-data" = local.k8s_dns_record
    "dev-airflow" = local.k8s_dns_record
    "dev" = local.k8s_dns_record
    "k8s" = local.k8s_dns_record
    "reports" = local.k8s_dns_record
    "www" = local.k8s_dns_record
    "_7d4337888553d4060717a3b3a0224834" = {type="CNAME", records=["_13e9708a2ab8d1e75414127fe18224de.dhzvlrndnj.acm-validations.aws."]}
    "email" = {type="CNAME", records=["mailgun.org."]}
    "media" = {type="CNAME", records=["anyway-infographics.web.app."]}
    "ws" = {type="CNAME", records=["anyway.co.il."]}
    "production" = {type="A", records=["35.233.114.242"]}
    "stage" = {type="A", records=["51.15.72.252"]}
    "test" = {type="A", records=["35.233.114.242"]}
  }
  oway_org_il_dns_records = {
    "stage" = {type="A", records=["138.68.112.226"]}
    "_446df89db6d3ca8ba6db1eff181484f9" = {type="CNAME", records=["_35e303c2df2669ca435b8b6770864a15.dhzvlrndnj.acm-validations.aws"]}
    "email" = {type="CNAME", records=["mailgun.org"]}
    "www" = local.k8s_dns_record
  }
}

data "aws_route53_zone" "anyway_co_il" {
  name         = "anyway.co.il."
  private_zone = false
}

data "aws_route53_zone" "oway_org_il" {
  name = "oway.org.il."
  private_zone = false
}

resource "aws_route53_record" "anyway_co_il" {
  for_each = local.anyway_co_il_dns_records
  zone_id = data.aws_route53_zone.anyway_co_il.zone_id
  type = each.value.type
  name = "${each.key}.${data.aws_route53_zone.anyway_co_il.name}"
  records = each.value.records
  ttl = "300"
}

resource "aws_route53_record" "anyway_co_il_root" {
  zone_id = data.aws_route53_zone.anyway_co_il.zone_id
  name = data.aws_route53_zone.anyway_co_il.name
  type = "A"
  alias {
    name                   = var.dfc_aws_lb_k8s_main_ingress.name
    zone_id                = var.dfc_aws_lb_k8s_main_ingress.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "oway_org_il" {
  for_each = local.oway_org_il_dns_records
  zone_id = data.aws_route53_zone.oway_org_il.zone_id
  type = each.value.type
  name = "${each.key}.${data.aws_route53_zone.oway_org_il.name}"
  records = each.value.records
  ttl = "300"
}

resource "aws_route53_record" "oway_org_il_root" {
  zone_id = data.aws_route53_zone.oway_org_il.zone_id
  name = data.aws_route53_zone.oway_org_il.name
  type = "A"
  alias {
    name                   = var.dfc_aws_lb_k8s_main_ingress.name
    zone_id                = var.dfc_aws_lb_k8s_main_ingress.zone_id
    evaluate_target_health = true
  }
}

output "anyway_co_il_ns_servers" {
  value = data.aws_route53_zone.anyway_co_il.name_servers
}

output "oway_org_il_ns_servers" {
  value = data.aws_route53_zone.oway_org_il.name_servers
}
