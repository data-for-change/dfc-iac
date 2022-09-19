resource "kubernetes_config_map" "tf_outputs" {
  metadata {
    name = "tf-outputs"
    namespace = "argocd"
  }

  data = merge(
    module.dfc.kubernetes_tf_outputs,
    module.anyway.kubernetes_tf_outputs
  )
}
