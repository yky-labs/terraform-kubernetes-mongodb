# (c) 2023 yky-labs
# This code is licensed under MIT license (see LICENSE for details)

variable "name" {
  type        = string
  description = "The database name"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace."
}

variable "create_namespace" {
  type        = bool
  description = "Create the Kunernetes namespace."
  default     = false
}

variable "members" {
  type        = number
  description = "MongoDB replica set members."
  default     = 1
}

variable "mongodb_version" {
  type        = string
  description = "MongoDB version."
}

variable "create_rbac" {
  type        = bool
  description = "Create the service account, role and role binding in the specified namespace."
  default     = true
}
