terraform {
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

#Default provider
provider "azurerm" {

  features {}
  tenant_id       = var.IB_TENANT_ID
  subscription_id = var.IB_SUB_441
  client_id       = var.IB_CLIENT_ID
  
}




#Default provider
provider "azurerm" {
  alias = "Sub-STG"
  features {}
  tenant_id       = var.IB_TENANT_ID
  subscription_id = var.IB_SUB_441
  client_id       = var.IB_CLIENT_ID
 
}


