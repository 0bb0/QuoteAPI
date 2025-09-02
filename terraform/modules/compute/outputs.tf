output "api_url" { value = azurerm_container_app.app.latest_revision_fqdn }
output "container_app_id" { value = azurerm_container_app.app.id }
output "identity_object_id" { value = azurerm_container_app.app.identity[0].principal_id }

