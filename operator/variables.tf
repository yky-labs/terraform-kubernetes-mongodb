# (c) 2023 yky-labs
# This code is licensed under MIT license (see LICENSE for details)

variable "name" {
  type        = string
  description = "The deploy name. Used to contextualize the name of the generated resources."
  default     = "mongodb-operator"
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

variable "chart_version" {
  type        = string
  description = "Helm Chart version."
  default     = null
}

variable "chart_values" {
  type        = list(string)
  description = "Additionals Helm Chart release values."
  default     = []
}

variable "watch_namespace" {
  type        = string
  description = "Namespaces to watch by the operator."
  default     = "*"
}
