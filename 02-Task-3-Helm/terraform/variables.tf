variable "namespace" {
  description = "The namespace where the app will be deployed in Kubernetes"
  type        = string
  default     = "fis-test" # Optionally set a default value
}

variable "docker_image_repository" {
  description = "The container registry repository for the application image"
  type        = string
  default     = "test.azurecr.io/01-node-app1" # Optionally set a default value
}

variable "image_tag" {
  description = "The tag for the application image"
  type        = string
  default     = "latest" # Optionally set a default value
}

variable "replica_count" {
  description = "The replica count"
  type        = number
  default     = 2
}

variable "max_replicas" {
  type    = number
  default = 4
}

variable "target_cpu_utilization" {
  type    = number
  default = 80
}

variable "target_memory_utilization" {
  type    = number
  default = 70
}

variable "hostname_prefix" {
  type    = string
  default = "nodeapp" # Optionally set a default value
}


variable "APP_NAME" {
  type    = string
  default = "nodeapp" # Optionally set a default value
}

variable "domain" {
  type    = string
  default = "wildcard.mk" # Optionally set a default value
}

variable "node_selector_key" {
  type        = string
  description = "Key for node selector"
  default     = "app"
}

variable "node_selector_value" {
  type        = string
  description = "Value for node selector"
  default     = "app-wildcard"
}

variable "resource_group_name" {
  type        = string
  description = "Value for node selector"
  default     = "rg-tr-dv-tt-northeurope-i2vb"
}

variable "cluster_name" {
  type        = string
  description = "Value for node selector"
  default     = "aks-tr-dv-tt-northeurope-i2vb"
}

variable "environment" {
  type        = string
  description = "Value for node selector"
  default     = "cluster"
}
