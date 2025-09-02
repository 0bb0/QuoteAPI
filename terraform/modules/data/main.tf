resource "random_password" "pg" {
  length  = 20
  special = true
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                          = var.pg_db_name
  resource_group_name           = var.rg_name
  location                      = var.location
  sku_name                      = var.pg_sku_name
  storage_mb                    = var.pg_storage_mb
  version                       = "16"
  administrator_login           = "pgadmin"
  administrator_password        = random_password.pg.result
  backup_retention_days         = var.pg_backup_days
  public_network_access_enabled = true
  tags                          = { project = var.project }
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.pg_db_name
  server_id = azurerm_postgresql_flexible_server.pg.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "azurerm_monitor_diagnostic_setting" "pg_diag" {
  name                       = "PostgreSQLDiagnostics"
  target_resource_id         = azurerm_postgresql_flexible_server.pg.id
  log_analytics_workspace_id = var.law_id
  enabled_metric { category = "AllMetrics" }
  enabled_log { category = "PostgreSQLLogs" }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allowed_ip" {
  name             = "operator-ip"
  server_id        = azurerm_postgresql_flexible_server.pg.id
  start_ip_address = var.operator_ip
  end_ip_address   = var.operator_ip
}

locals {
  host = azurerm_postgresql_flexible_server.pg.fqdn
  port = 5432
  user = azurerm_postgresql_flexible_server.pg.administrator_login
  pass = urlencode(azurerm_postgresql_flexible_server.pg.administrator_password)
  dsn  = "postgresql://${local.user}:${local.pass}@${local.host}:${local.port}/${azurerm_postgresql_flexible_server_database.db.name}?sslmode=require"
}

