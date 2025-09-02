locals {
  app_name = "${var.project}-quoteapi"
}

resource "azurerm_container_app_environment" "env" {
  name                = "${var.project}-ca-env"
  location            = var.location
  resource_group_name = var.rg_name

  tags = {
    project = var.project
  }
}

resource "azurerm_container_app" "app" {
  name                         = local.app_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.rg_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {
    min_replicas = var.instance_count
    max_replicas = var.instance_count
    container {
      name   = "quoteapi"
      image  = "${var.container_image}:${var.container_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "DB_CONNECTION_STRING"
        value = "secretref:db-conn-str"
      }

    }
  }

  secret {
    name  = "db-conn-str"
    value = var.kv_secret_uri
  }

  ingress {
    external_enabled = true
    target_port      = var.container_port
    transport        = "auto"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = {
    project = var.project
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id = var.kv_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_container_app.app.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_monitor_diagnostic_setting" "app_diag" {
  name                       = "${var.project}-app-diag"
  target_resource_id         = azurerm_container_app.app.id
  log_analytics_workspace_id = var.law_id
  enabled_metric { category = "AllMetrics" }
}

resource "azurerm_monitor_diagnostic_setting" "env_logs" {
  name                       = "${var.project}-env-logs"
  target_resource_id         = azurerm_container_app_environment.env.id
  log_analytics_workspace_id = var.law_id
  enabled_log { category = "ContainerAppConsoleLogs" }
  enabled_log { category = "ContainerAppSystemLogs" }
}

resource "azurerm_monitor_metric_alert" "http5xx_count" {
  name                = "quoteapi-poc-5xx-count"
  resource_group_name = var.rg_name
  scopes              = [azurerm_container_app.app.id]
  description         = "5xx requests in the last 5m exceed threshold"
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"
  auto_mitigate       = true

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "Requests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10 # adjust for your traffic

    dimension {
      name     = "statusCodeCategory"
      operator = "Include"
      values   = ["5xx"]
    }
  }
  action {
    action_group_id = var.action_group_id
  }
}

