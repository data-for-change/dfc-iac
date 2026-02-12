locals {
  dfc2_k8s_dns_record = {type="CNAME", records=[var.dfc2_main_docker_hostname]}
  dfc2_anyway_co_il_dns_records = {
    "airflow-data" = local.dfc2_k8s_dns_record
    "airflow" = local.dfc2_k8s_dns_record
    "reports" = local.dfc2_k8s_dns_record
    "www" = local.dfc2_k8s_dns_record
    "safety-data" = local.dfc2_k8s_dns_record
    "ws" = {type="CNAME", records=["dfc2.anyway.co.il."]}
  }
}

resource "aws_route53_record" "dfc2_anyway_co_il" {
  for_each = local.dfc2_anyway_co_il_dns_records
  zone_id = data.aws_route53_zone.anyway_co_il.zone_id
  type = each.value.type
  name = "${each.key}.dfc2.${data.aws_route53_zone.anyway_co_il.name}"
  records = each.value.records
  ttl = "300"
}

resource "aws_route53_record" "dfc2_anyway_co_il_root" {
  zone_id = data.aws_route53_zone.anyway_co_il.zone_id
  name = "dfc2.${data.aws_route53_zone.anyway_co_il.name}"
  type = "A"
  records = [var.dfc2_main_docker_ip]
  ttl = "300"
}
