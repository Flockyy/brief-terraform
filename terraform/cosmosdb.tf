# Cosmos DB for PostgreSQL (Citus)

resource "azurerm_cosmosdb_postgresql_cluster" "main" {
  name                            = "cosmos-${var.project_name}-${var.environment}"
  resource_group_name             = data.azurerm_resource_group.main.name
  location                        = data.azurerm_resource_group.main.location
  administrator_login_password    = var.postgres_admin_password
  coordinator_storage_quota_in_mb = 32768
  coordinator_vcore_count         = 1
  node_count                      = 0
  coordinator_server_edition      = "BurstableMemoryOptimized"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Firewall rule to allow Azure services
resource "azurerm_cosmosdb_postgresql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  cluster_id       = azurerm_cosmosdb_postgresql_cluster.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Optional: Firewall rule for your IP address
resource "azurerm_cosmosdb_postgresql_firewall_rule" "client_ip" {
  count            = var.allowed_ip_address != "" ? 1 : 0
  name             = "AllowClientIP"
  cluster_id       = azurerm_cosmosdb_postgresql_cluster.main.id
  start_ip_address = var.allowed_ip_address
  end_ip_address   = var.allowed_ip_address
}
