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
  tenant_id       = var.IB_Tenant_id
  subscription_id = var.IB_Sub_STG
  client_id       = var.IB_Sub_STG_appid
  client_secret   = var.IB_Sub_STG_st
}




#Default provider
provider "azurerm" {
  alias = "Sub-STG"
  features {}
  tenant_id       = var.IB_Tenant_id
  subscription_id = var.IB_Sub_STG
  client_id       = var.IB_Sub_STG_appid
  client_secret   = var.IB_Sub_STG_st
}


