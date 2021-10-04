terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.79.1"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}