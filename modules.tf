module "anyway" {
  source = "./modules/anyway"
  dfc_main_docker_hostname = module.dfc.main_docker_hostname
  dfc_main_docker_ip = module.dfc.main_docker_ip
}

# these nameservers need to be set manually in LiveDNS domain management
#output "anyway_co_il_ns_servers" {value = module.anyway.anyway_co_il_ns_servers}
#output "oway_org_il_ns_servers" {value = module.anyway.oway_org_il_ns_servers}
output "anyway_healthchecks_alarms" {value = module.anyway.anyway_healthchecks_alarms}

module "dfc" {
  source = "./modules/dfc"
  infrastructure_root_domain = var.infrastructure_root_domain
}
