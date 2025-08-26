# https://www.terraform.io/docs/configuration/variables.html
# Input Variables
# Output Values
# Local Values (Optional)

# Azure AKS Environment Name
variable "ad_group_name" {
  default     = "group"
  description = "This is AD Group name var"
  type        = string
}

# Azure AKS Environment Name
variable "environment" {
  default     = "stag"
  description = "This is Environment var"
  type        = string
}
