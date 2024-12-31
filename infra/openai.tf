resource "random_integer" "this" {
  max = 999999
  min = 100000
}
locals {
  account_name          = coalesce(var.account_name, "azure-openai-${random_integer.this.result}")
  custom_subdomain_name = coalesce(var.custom_subdomain_name, "azure-openai-${random_integer.this.result}")
}

resource "azurerm_cognitive_account" "this" {
  kind                          = "OpenAI"
  location                      = azurerm_resource_group.this.location
  name                          = local.account_name
  resource_group_name           = azurerm_resource_group.this.name
  sku_name                      = var.sku_name
  custom_subdomain_name         = local.custom_subdomain_name
  public_network_access_enabled = false
}

resource "azurerm_cognitive_deployment" "this" {
  cognitive_account_id = azurerm_cognitive_account.this.id
  name                 = "gpt-4"
  sku {
    name = "Standard"
  }
  model {
    format  = "OpenAI"
    name    = var.chat_model_name
    version = var.chat_model_version
  }
}