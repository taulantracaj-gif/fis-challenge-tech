# Create Azure AD Group in Active Directory 
resource "azuread_group" "az_ad_group" {
  display_name     = upper(var.ad_group_name)
  description      = "Azure AD group ${var.ad_group_name}-${var.environment}."
  security_enabled = true
}
