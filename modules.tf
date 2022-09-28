module "anyway" {
  source = "./modules/anyway"
  dfc_aws_lb_k8s_main_ingress = module.dfc.aws_lb_k8s_main_ingress
  dfc_k8s_main_ingress_hostname = module.dfc.k8s_main_ingress_hostname
}
# these nameservers need to be set manually in LiveDNS domain management
output "anyway_co_il_ns_servers" {value = module.anyway.anyway_co_il_ns_servers}
output "oway_org_il_ns_servers" {value = module.anyway.oway_org_il_ns_servers}

module "dfc" {
  source = "./modules/dfc"
  infrastructure_root_domain = var.infrastructure_root_domain
}
