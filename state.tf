provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 0.15"  # Terraform client version

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.57.0"       # AzureRM provider version
    }
  }
}