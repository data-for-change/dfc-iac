module "anyway" {
  source = "./modules/anyway"
}
# these nameservers need to be set manually in LiveDNS domain management
output "anyway_co_il_ns_servers" {value = module.anyway.anyway_co_il_ns_servers}
output "oway_org_il_ns_servers" {value = module.anyway.oway_org_il_ns_servers}

module "dfc" {
  source = "./modules/dfc"
  infrastructure_root_domain = var.infrastructure_root_domain
}
