# (c) 2023 yky-labs
# This code is licensed under MIT license (see LICENSE for details)

locals {
  namespace = (var.create_namespace) ? kubernetes_namespace_v1.this[0].metadata[0].name : var.namespace
}

resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

# https://github.com/mongodb/helm-charts/tree/main/charts/community-operator

resource "helm_release" "this" {
  namespace  = local.namespace
  repository = "https://mongodb.github.io/helm-charts"
  chart      = "community-operator"
  name       = var.name
  version    = var.chart_version
  values = concat([
    <<-EOF
    operator:
      watchNamespace: "${var.watch_namespace}"
    EOF
  ], var.chart_values)

  depends_on = [
    kubernetes_namespace_v1.this
  ]
}
