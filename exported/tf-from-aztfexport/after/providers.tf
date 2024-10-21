terraform {
  cloud {
    organization = "組織名"
    hostname     = "app.terraform.io"
    workspaces {
      name = "ワークスペース名"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}
provider "azurerm" {
  features {}
}