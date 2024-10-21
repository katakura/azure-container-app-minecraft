resource "azurerm_resource_group" "main" {
  location = "japaneast"
  name     = "rg-minecraft-java-server"
}
resource "azurerm_container_app" "mcjava" {
  container_app_environment_id = "/subscriptions/SUBSCRIPTIONID/resourceGroups/rg-minecraft-java-server/providers/Microsoft.App/managedEnvironments/acaenv-minecraft"
  name                         = "minecraft"
  resource_group_name          = "rg-minecraft-java-server"
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
  depends_on = [
    azurerm_container_app_environment.main,
  ]
}
resource "azurerm_container_app_environment" "main" {
  infrastructure_subnet_id = "/subscriptions/SUBSCRIPTIONID/resourceGroups/rg-minecraft-java-server/providers/Microsoft.Network/virtualNetworks/vnet-minecraft/subnets/snet-aca"
  location                 = "japaneast"
  name                     = "acaenv-minecraft"
  resource_group_name      = "rg-minecraft-java-server"
  depends_on = [
    azurerm_subnet.aca,
  ]
}
resource "azurerm_container_app_environment_storage" "main" {
  access_key                   = ""
  access_mode                  = "ReadWrite"
  account_name                 = "stminecraftz6g4sa4sns7fw"
  container_app_environment_id = "/subscriptions/SUBSCRIPTIONID/resourceGroups/rg-minecraft-java-server/providers/Microsoft.App/managedEnvironments/acaenv-minecraft"
  name                         = "mcdata"
  share_name                   = "mcdata"
  depends_on = [
    azurerm_container_app_environment.main,
  ]
}
resource "azurerm_virtual_network" "main" {
  address_space       = ["10.10.0.0/16"]
  location            = "japaneast"
  name                = "vnet-minecraft"
  resource_group_name = "rg-minecraft-java-server"
  depends_on = [
    azurerm_resource_group.main,
  ]
}
resource "azurerm_subnet" "aca" {
  address_prefixes     = ["10.10.0.0/23"]
  name                 = "snet-aca"
  resource_group_name  = "rg-minecraft-java-server"
  service_endpoints    = ["Microsoft.Storage"]
  virtual_network_name = "vnet-minecraft"
  depends_on = [
    azurerm_virtual_network.main,
  ]
}
resource "azurerm_log_analytics_workspace" "main" {
  location            = "japaneast"
  name                = "log-minecraft"
  resource_group_name = "rg-minecraft-java-server"
  depends_on = [
    azurerm_resource_group.main,
  ]
}
resource "azurerm_storage_account" "main" {
  account_kind                     = "FileStorage"
  account_replication_type         = "LRS"
  account_tier                     = "Premium"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  location                         = "japaneast"
  min_tls_version                  = "TLS1_0"
  name                             = "stminecraftz6g4sa4sns7fw"
  resource_group_name              = "rg-minecraft-java-server"
  depends_on = [
    azurerm_resource_group.main,
  ]
}
resource "azurerm_storage_share" "mcdata" {
  name                 = "mcdata"
  quota                = 100
  storage_account_name = "stminecraftz6g4sa4sns7fw"
}
