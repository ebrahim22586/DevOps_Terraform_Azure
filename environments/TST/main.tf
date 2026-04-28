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

provider "azurerm" { 
  alias = "Sub-TST"
  features {}
  tenant_id       = var.IB_Tenant_id
  subscription_id = var.IB_Sub_TST
  client_id       = var.IB_Sub_TST_appid
  client_secret   = var.IB_Sub_TST_st
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


provider "azurerm" {
  alias = "Sub-PRD"
  features {}
  tenant_id       = var.IB_Tenant_id
  subscription_id = var.IB_Sub_PRD
  client_id       = var.IB_Sub_PRD_appid
  client_secret   = var.IB_Sub_PRD_st
}
