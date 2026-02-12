module "anyway" {
  source = "./modules/anyway"
  dfc_main_docker_hostname = module.dfc.main_docker_hostname
  dfc_main_docker_ip = module.dfc.main_docker_ip
  dfc2_main_docker_hostname = module.dfc2.main_docker_hostname
  dfc2_main_docker_ip = module.dfc2.main_docker_ip
}

# these nameservers need to be set manually in LiveDNS domain management
#output "anyway_co_il_ns_servers" {value = module.anyway.anyway_co_il_ns_servers}
#output "oway_org_il_ns_servers" {value = module.anyway.oway_org_il_ns_servers}
output "anyway_healthchecks_alarms" {value = module.anyway.anyway_healthchecks_alarms}

module "dfc" {
  source = "./modules/dfc"
  infrastructure_root_domain = var.infrastructure_root_domain
}

module "dfc2" {
  source = "./modules/dfc"
  infrastructure_root_domain = var.infrastructure_root_domain
  name_prefix = "dfc2-"
  vpc_id = "vpc-028a1b06928595f30"
  subnet_cidr = "172.31.48.0/20"
  security_group_id = "sg-00ae1cb00f5f12fe5"
  vault_policies = []
  vault_approles = []
  aws_default_ssh_key_name = var.aws_default_ssh_key_name
}
