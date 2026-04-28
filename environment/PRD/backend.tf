terraform {


  backend "azurerm" {

    tenant_id            = "59d38026-3cd2-4194-8eb6-e56ee9eeffcd"
    subscription_id      = "6fffa98c-3cf6-4729-bb78-3e4ae94eefaf"
    storage_account_name = "backendsaterrazure"
    container_name       = "tfstate"
    key                  = "terraformt/fstate"
  }



}