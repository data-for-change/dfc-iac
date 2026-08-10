locals {
  k8s_dns_record = {type="CNAME", records=[var.dfc_main_docker_hostname]}
  anyway_co_il_dns_records = {
    "airflow-data" = local.k8s_dns_record
    "airflow" = local.k8s_dns_record
    "reports" = local.k8s_dns_record
    "www" = local.k8s_dns_record
    "safety-data" = {type="CNAME", records=["safety-data.dfc2.anyway.co.il"]}
    "email" = {type="CNAME", records=["mailgun.org."]}
    "media" = {type="CNAME", records=["anyway-infographics.web.app."]}
    "ws" = {type="CNAME", records=["anyway.co.il."]}
    "qpixbm5opqtcsv64uhbfd476sbxca6wd._domainkey" = {
      type    = "CNAME"
      records = ["qpixbm5opqtcsv64uhbfd476sbxca6wd.dkim.amazonses.com."]
    }
    "uu4k534e6aixnupykf5u3zjmbwd6s2cx._domainkey" = {
      type    = "CNAME"
      records = ["uu4k534e6aixnupykf5u3zjmbwd6s2cx.dkim.amazonses.com."]
    }
    "lojh3b5ywy5hrtpf7fgln4b4t5doqosn._domainkey" = {
      type    = "CNAME"
      records = ["lojh3b5ywy5hrtpf7fgln4b4t5doqosn.dkim.amazonses.com."]
    }
  }
  oway_org_il_dns_records = {
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
  records = [var.dfc_main_docker_ip]
  ttl = "300"
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
  records = [var.dfc_main_docker_ip]
  ttl = "300"
}

output "anyway_co_il_ns_servers" {
  value = data.aws_route53_zone.anyway_co_il.name_servers
}

output "oway_org_il_ns_servers" {
  value = data.aws_route53_zone.oway_org_il.name_servers
}
