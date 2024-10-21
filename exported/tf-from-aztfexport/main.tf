variable "resource_group_name" {
  default = "rg-minecraft-java-server"
}
variable "location" {
  default = "japaneast"
}

resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_resource_group" "main" {
  location = var.location
  name     = var.resource_group_name
}
resource "azurerm_container_app" "mcjava" {
  container_app_environment_id = azurerm_container_app_environment.main.id
  name                         = "minecraft"
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  ingress {
    exposed_port     = 25565
    external_enabled = true
    target_port      = 25565
    transport        = "tcp"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
  template {
    max_replicas = 1
    container {
      cpu    = 1
      image  = "docker.io/itzg/minecraft-server:latest"
      memory = "2Gi"
      name   = "minecraft"
      env {
        name  = "EULA"
        value = "TRUE"
      }
      env {
        name  = "UID"
        value = "0"
      }
      env {
        name  = "GID"
        value = "0"
      }
      env {
        name  = "MAX_PLAYERS"
        value = "5"
      }
      env {
        name  = "MODE"
        value = "survival"
      }
      env {
        name  = "DIFFICULTY"
        value = "normal"
      }
      volume_mounts {
        name = "mcdata"
        path = "/data"
      }
    }
    volume {
      name         = "mcdata"
      storage_name = "mcdata"
      storage_type = "AzureFile"
    }
  }
}
resource "azurerm_container_app_environment" "main" {
  infrastructure_subnet_id   = azurerm_subnet.aca.id
  location                   = azurerm_resource_group.main.location
  name                       = "acaenv-minecraft"
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}
resource "azurerm_container_app_environment_storage" "main" {
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"
  account_name                 = azurerm_storage_account.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  name                         = "mcdata"
  share_name                   = "mcdata"
}
resource "azurerm_virtual_network" "main" {
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.main.location
  name                = "vnet-minecraft"
  resource_group_name = azurerm_resource_group.main.name
}
resource "azurerm_subnet" "aca" {
  address_prefixes     = ["10.10.0.0/23"]
  name                 = "snet-aca"
  resource_group_name  = azurerm_resource_group.main.name
  service_endpoints    = ["Microsoft.Storage"]
  virtual_network_name = azurerm_virtual_network.main.name
}
resource "azurerm_log_analytics_workspace" "main" {
  location            = azurerm_resource_group.main.location
  name                = "log-minecraft"
  resource_group_name = azurerm_resource_group.main.name
}
resource "azurerm_storage_account" "main" {
  account_kind                     = "FileStorage"
  account_replication_type         = "LRS"
  account_tier                     = "Premium"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  location                         = azurerm_resource_group.main.location
  min_tls_version                  = "TLS1_2"
  name                             = "stmc${lower(random_id.storage_account.hex)}"
  resource_group_name              = azurerm_resource_group.main.name
}
resource "azurerm_storage_share" "mcdata" {
  name                 = "mcdata"
  quota                = 100
  storage_account_name = azurerm_storage_account.main.name
}
resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = "log-minecraft"
  target_resource_id         = azurerm_container_app_environment.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  enabled_log {
    category_group = "allLogs"
  }
}
