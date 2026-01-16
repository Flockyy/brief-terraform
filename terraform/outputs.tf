# Output values for easy access to resource information

output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "container_registry_name" {
  description = "Name of the container registry"
  value       = azurerm_container_registry.main.name
}

output "container_registry_login_server" {
  description = "Login server URL for the container registry"
  value       = azurerm_container_registry.main.login_server
}

output "container_registry_admin_username" {
  description = "Admin username for ACR"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "container_registry_admin_password" {
  description = "Admin password for ACR"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

output "postgres_host" {
  description = "PostgreSQL host address - get actual FQDN with: az cosmosdb postgres cluster show --name cosmos-nyctaxi-dev --resource-group fabgrallRG --query serverNames[0].fullyQualifiedDomainName -o tsv"
  value       = "c-cosmos-nyctaxi-dev.adrouv6ibhgkvf.postgres.cosmos.azure.com"
}

output "postgres_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${var.postgres_admin_username}:${var.postgres_admin_password}@c-cosmos-nyctaxi-dev.adrouv6ibhgkvf.postgres.cosmos.azure.com:5432/citus?sslmode=require"
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "container_app_name" {
  description = "Name of the container app"
  value       = azurerm_container_app.pipeline.name
}

output "container_app_fqdn" {
  description = "FQDN of the container app"
  value       = azurerm_container_app.pipeline.latest_revision_fqdn
}
