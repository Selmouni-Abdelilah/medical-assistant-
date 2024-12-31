resource "azurerm_application_insights" "main" {
  name                = "medical-form-app-insights"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  application_type    = "other"

}

resource "azurerm_storage_account" "strg_acc" {
  name                     = "medicalformsa"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "svc_plan" {
  name                = "medical-form-service-plan"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "B3"
}

resource "azurerm_linux_function_app" "func_app" {
  name                = "medical-form-function-app"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  storage_account_name       = azurerm_storage_account.strg_acc.name
  storage_account_access_key = azurerm_storage_account.strg_acc.primary_access_key
  service_plan_id            = azurerm_service_plan.svc_plan.id
  virtual_network_subnet_id  = module.vnet.subnets.subnet-b.resource_id
  https_only                 = true
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"            = "python"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"      = "1"
    "ENABLE_ORYX_BUILD"                   = "true"
    "BUILD_FLAGS"                         = "UseExpressBuild"
    "DOCKER_REGISTRY_SERVER_URL"          = format("https://%s", azurerm_container_registry.acr.login_server)
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.acr.admin_password
  }
  connection_string {
    name  = "AZURE_OPENAI_API_KEY"
    type  = "Custom"
    value = azurerm_cognitive_account.this.primary_access_key
  }
  connection_string {
    name  = "AZURE_OPENAI_ENDPOINT"
    type  = "Custom"
    value = azurerm_cognitive_account.this.endpoint
  }
  connection_string {
    name  = "DB_NAME"
    type  = "Custom"
    value = azurerm_mssql_database.mssql-db.name
  }
  connection_string {
    name  = "DB_USER"
    type  = "Custom"
    value = azurerm_mssql_server.mssql-server.administrator_login
  }
  connection_string {
    name  = "DB_PASSWORD"
    type  = "Custom"
    value = azurerm_mssql_server.mssql-server.administrator_login_password
  }
  connection_string {
    name  = "DB_HOST"
    type  = "Custom"
    value = azurerm_mssql_server.mssql-server.name
  }

  site_config {
    application_insights_connection_string = azurerm_application_insights.main.connection_string
    application_insights_key               = azurerm_application_insights.main.instrumentation_key
    always_on                              = true
    ftps_state                             = "Disabled"
    http2_enabled                          = true
    application_stack {
      docker {
       image_name        = "medicalformacr"
       image_tag         = "latest" 
       registry_password = azurerm_container_registry.acr.admin_password
       registry_url      = format("https://%s", azurerm_container_registry.acr.login_server)
       registry_username = azurerm_container_registry.acr.admin_username
      }
    }
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = false
    }
  }
  lifecycle {
    ignore_changes = [
    app_settings,
    site_config,
  ]
  }
  
}
