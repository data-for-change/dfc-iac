variable "dfc_aws_lb_k8s_main_ingress" {
  type = object({
    name = string
    dns_name = string
    zone_id = string
  })
}

variable "dfc_k8s_main_ingress_hostname" {
  type = string
}
