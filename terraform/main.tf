# Main Terraform configuration

# Generate random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Use existing Resource Group
data "azurerm_resource_group" "main" {
  name = "fabgrallRG"
}
