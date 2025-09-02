output "db_name" { value = azurerm_postgresql_flexible_server_database.db.name }
output "db_host" { value = local.host }
output "db_user" { value = local.user }
output "db_pass" { value = local.pass }
output "connection_string" {
  value     = local.dsn
  sensitive = true
}

