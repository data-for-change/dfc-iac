output "kubernetes_tf_outputs" {
  value = {
    argocd_domain_name = cloudflare_record.k8s_main_ingress_target["argocd"].hostname
    argocd_grpc_domain_name = cloudflare_record.k8s_main_ingress_target["argocd-grpc"].hostname
    grafana_domain_name = cloudflare_record.k8s_main_ingress_target["grafana"].hostname
    vault_domain_name = cloudflare_record.k8s_main_ingress_target["vault"].hostname
  }
}
