module "anyway" {
  source = "./modules/anyway"
}

module "dfc" {
  source = "./modules/dfc"
  infrastructure_root_domain = var.infrastructure_root_domain
}
