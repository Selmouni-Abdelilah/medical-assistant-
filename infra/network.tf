module "vnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.52.0.0/16"]
  location            = var.region
  name                = "vnet"
  subnets = {
    subnet-a = {
      name              = "subnet-a"
      address_prefixes  = ["10.52.0.0/24"]
      service_endpoints = ["Microsoft.CognitiveServices"]
    }
    subnet-b = {
      name             = "subnet-b"
      address_prefixes = ["10.52.1.0/24"]
      delegation = [{
        name = "delegation"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
        }
      }]
    }
  }
}

# Create private endpoint for OpenAI account
resource "azurerm_private_dns_zone" "openai_dns_zone" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.this.name
}
resource "azurerm_private_endpoint" "openai-pe" {
  location            = azurerm_resource_group.this.location
  name                = "openai-pe"
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.vnet.subnets.subnet-a.resource_id
  private_service_connection {
    is_manual_connection           = false
    name                           = "openai_pe_connection"
    private_connection_resource_id = azurerm_cognitive_account.this.id
    subresource_names              = ["account"]
  }
  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.openai_dns_zone.name
    private_dns_zone_ids = [azurerm_private_dns_zone.openai_dns_zone.id]
  }
}
resource "azurerm_private_dns_zone_virtual_network_link" "openai_dns_zone_link" {
  name                  = "openai-acc-pe-vlink"
  private_dns_zone_name = azurerm_private_dns_zone.openai_dns_zone.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = module.vnet.resource_id
  registration_enabled  = false
}

# Create private endpoint for Storage Account
resource "azurerm_private_dns_zone" "strgacc_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}
resource "azurerm_private_endpoint" "strg-acc-pe" {
  location            = azurerm_resource_group.this.location
  name                = "strg-acc-pe"
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.vnet.subnets.subnet-a.resource_id
  private_service_connection {
    is_manual_connection           = false
    name                           = "strg-acc_pe_connection"
    private_connection_resource_id = azurerm_storage_account.strg_acc.id
    subresource_names              = ["blob"]
  }
  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.openai_dns_zone.name
    private_dns_zone_ids = [azurerm_private_dns_zone.openai_dns_zone.id]
  }
}
resource "azurerm_private_dns_zone_virtual_network_link" "strg_dns_zone_link" {
  name                  = "strg-acc-pe-vlink"
  private_dns_zone_name = azurerm_private_dns_zone.strgacc_dns_zone.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = module.vnet.resource_id
  registration_enabled  = false
}

# Create private endpoint for SQL server
# resource "azurerm_private_dns_zone" "sql_dns_zone" {
#   name                = "${azurerm_mssql_server.mssql-server.name}.database.windows.net"
#   resource_group_name = azurerm_resource_group.this.name
# }
# resource "azurerm_private_endpoint" "sql_pe" {
#   name                = "private-endpoint-sql"
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name
#   subnet_id           = module.vnet.subnets.subnet-a.resource_id

#   private_service_connection {
#     name                           = "sql-serviceconnection"
#     private_connection_resource_id = azurerm_mssql_server.mssql-server.id
#     subresource_names              = ["sqlServer"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "dns-zone-group"
#     private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns_zone.id]
#   }
# }
# resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_zone_link" {
#   name                  = "sql-pe-vlink"
#   private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
#   resource_group_name   = azurerm_resource_group.this.name
#   virtual_network_id    = module.vnet.resource_id
#   registration_enabled  = false
# }