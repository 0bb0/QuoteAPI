resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.project}-law"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = { project = var.project }
}

resource "azurerm_monitor_action_group" "ag" {
  name                = "${var.project}-ag"
  resource_group_name = var.rg_name
  short_name          = substr(var.project, 0, 12)

  dynamic "email_receiver" {
    for_each = var.alert_email != "" ? [1] : []
    content {
      name          = "primary"
      email_address = var.alert_email
    }
  }
}
