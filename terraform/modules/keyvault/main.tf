data "azurerm_client_config" "current" {}

resource "random_string" "kv_suffix" {
  length  = 4
  upper   = false
  special = false
}


resource "azurerm_key_vault" "kv" {
  name                          = "${var.project}-kv-${random_string.kv_suffix.result}"
  location                      = var.location
  resource_group_name           = var.rg_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.kv_sku
  soft_delete_retention_days    = 7
  purge_protection_enabled      = var.kv_purge_protect
  public_network_access_enabled = true
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = []
    ip_rules                   = [var.operator_ip]
  }
  tags = { project = var.project }
}

resource "azurerm_key_vault_access_policy" "terraform_operator" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge"
  ]
}

resource "azurerm_key_vault_secret" "db" {
  name            = "db-connstr"
  value           = var.db_conn_str
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "text/plain"
  expiration_date = timeadd(timestamp(), "8760h")
  depends_on      = [azurerm_key_vault_access_policy.terraform_operator]
}
