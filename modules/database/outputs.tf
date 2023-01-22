# (c) 2023 yky-labs
# This code is licensed under MIT license (see LICENSE for details)

output "admin_password" {
  value       = kubernetes_secret_v1.admin_password.data["password"]
  sensitive   = true
  description = "The admin user password."
}
