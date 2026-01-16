# Container Apps Environment and Application

resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.project_name}-${var.environment}"
  resource_group_name        = data.azurerm_resource_group.main.name
  location                   = data.azurerm_resource_group.main.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_container_app" "pipeline" {
  name                         = "ca-${var.project_name}-pipeline-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"

  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry.main.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.main.admin_password
  }

  secret {
    name  = "storage-connection-string"
    value = azurerm_storage_account.main.primary_connection_string
  }

  secret {
    name  = "postgres-password"
    value = var.postgres_admin_password
  }

  template {
    container {
      name   = "nyc-taxi-pipeline"
      image  = "${azurerm_container_registry.main.login_server}/nyc-taxi-pipeline:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "AZURE_CONTAINER_NAME"
        value = "raw"
      }

      env {
        name        = "AZURE_STORAGE_CONNECTION_STRING"
        secret_name = "storage-connection-string"
      }

      env {
        name  = "POSTGRES_HOST"
        value = "c-cosmos-nyctaxi-dev.j3gmskci73hpbt.postgres.cosmos.azure.com"
      }

      env {
        name  = "POSTGRES_PORT"
        value = "5432"
      }

      env {
        name  = "POSTGRES_DB"
        value = "citus"
      }

      env {
        name  = "POSTGRES_USER"
        value = "citus"
      }

      env {
        name        = "POSTGRES_PASSWORD"
        secret_name = "postgres-password"
      }

      env {
        name  = "POSTGRES_SSL_MODE"
        value = "require"
      }

      env {
        name  = "START_DATE"
        value = var.start_date
      }

      env {
        name  = "END_DATE"
        value = var.end_date
      }
    }

    min_replicas = 0
    max_replicas = 1
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
