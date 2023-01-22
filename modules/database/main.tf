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

# https://github.com/mongodb/mongodb-kubernetes-operator/issues/1069#issuecomment-1276355435
# https://github.com/mongodb/mongodb-kubernetes-operator/tree/master/config/rbac

resource "kubernetes_service_account_v1" "this" {
  count = (var.create_rbac) ? 1 : 0

  metadata {
    name      = "mongodb-database"
    namespace = local.namespace
  }
}

resource "kubernetes_role_v1" "this" {
  count = (var.create_rbac) ? 1 : 0

  metadata {
    name      = "mongodb-database"
    namespace = local.namespace
  }
  rule {
    api_groups = [ "" ]
    resources  = [ "secrets" ]
    verbs      = [ "get" ]
  }
  rule {
    api_groups = [ "" ]
    resources  = [ "pods" ]
    verbs      = [ "patch", "delete", "get" ]
  }
}

resource "kubernetes_role_binding_v1" "this" {
  count = (var.create_rbac) ? 1 : 0

  metadata {
    name      = "mongodb-database"
    namespace = local.namespace
  }
  subject {
    kind      = "ServiceAccount"
    name      = "mongodb-database"
    namespace = local.namespace
  }
  role_ref {
    kind = "Role"
    name = "mongodb-database"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    kubernetes_service_account_v1.this,
    kubernetes_role_v1.this
  ]
}

resource "random_password" "admin_password" {
  length      = 32
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}

resource "kubernetes_secret_v1" "admin_password" {
  metadata {
    name      = "${var.name}-admin-password"
    namespace = local.namespace
  }
  data = {
    "password" = random_password.admin_password.result
  }
}

# https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/config/samples/mongodb.com_v1_mongodbcommunity_cr.yaml

resource "kubectl_manifest" "this" {

  yaml_body = <<-EOF

    apiVersion: mongodbcommunity.mongodb.com/v1
    kind: MongoDBCommunity
    metadata:
      name: ${var.name}
      namespace: ${local.namespace}
    spec:
      members: ${var.members}
      type: ReplicaSet
      version: ${var.mongodb_version}
      security:
        authentication:
          modes: ["SCRAM"]
      users:
        - name: admin
          db: admin
          passwordSecretRef:
            name: ${kubernetes_secret_v1.admin_password.metadata[0].name}
          roles:
            - name: clusterAdmin
              db: admin
            - name: userAdminAnyDatabase
              db: admin
          scramCredentialsSecretName: ${var.name}-admin-user

  EOF

  depends_on = [
    kubernetes_secret_v1.admin_password,
    kubernetes_role_binding_v1.this
  ]
}
