terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "tfstatequoteapi280825"
    container_name       = "tfstate"
    key                  = "quoteapi-poc.tfstate"
  }
}
