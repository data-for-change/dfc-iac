data "cloudflare_zone" "infrastructure_root_domain" {
  name = var.infrastructure_root_domain
}

resource "cloudflare_record" "main_docker" {
  zone_id = data.cloudflare_zone.infrastructure_root_domain.id
  name    = "docker-main"
  value   = aws_eip.main_docker.public_ip
  type    = "A"
  allow_overwrite = false
  timeouts {}
}

resource "cloudflare_record" "main_docker_target" {
  zone_id = data.cloudflare_zone.infrastructure_root_domain.id
  name    = "*"
  value   = "${cloudflare_record.main_docker.name}.${data.cloudflare_zone.infrastructure_root_domain.name}"
  type    = "CNAME"
}

output "main_docker_hostname" {
  value = "${cloudflare_record.main_docker.name}.${data.cloudflare_zone.infrastructure_root_domain.name}"
}
