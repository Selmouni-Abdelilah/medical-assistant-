resource "azurerm_resource_group" "this" {
  location = var.region
  name     = "medical-form-infra-rg-${var.region}"
}