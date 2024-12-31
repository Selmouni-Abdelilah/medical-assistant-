# Azure provider version
terraform {
  required_version = ">= 1.9.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend-state"
    storage_account_name = "4terraformgsprac"
    container_name       = "tfstate"
    key                  = "medical-form.tfstate"

  }
}

provider "azurerm" {
  features {

  }
  subscription_id = "07cfeda7-60f3-4f0e-8844-42f3057ba5bb"
}

provider "random" {}