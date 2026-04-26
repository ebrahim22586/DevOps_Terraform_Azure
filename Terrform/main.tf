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
  tenant_id       = var.IB-Tenant-id
  subscription_id = var.IB-Sub-STG
  client_id       = var.IB-Sub-STG_appid
  client_secret   = var.IB-Sub-STG_st
}

provider "azurerm" { 
  alias = "SUb-TST"
  features {}
  tenant_id       = var.IB-Tenant-id
  subscription_id = var.IB-Sub-TST
  client_id       = var.IB-Sub-TST_appid
  client_secret   = var.IB-Sub-TST_st
}

#Default provider
provider "azurerm" {
  alias = "Sub-STG"
  features {}
  tenant_id       = var.IB-Tenant-id
  subscription_id = var.IB-Sub-STG
  client_id       = var.IB-Sub-STG_appid
  client_secret   = var.IB-Sub-STG_st
}


provider "azurerm" {
  alias = "SUb-PRD"
  features {}
  tenant_id       = var.IB-Tenant-id
  subscription_id = var.IB-Sub-PRD
  client_id       = var.IB-Sub-PRD_appid
  client_secret   = var.IB-Sub-PRD_st
}
