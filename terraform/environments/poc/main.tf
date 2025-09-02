provider "azurerm" {
  features {}
  subscription_id = "fa127f23-4720-4538-b725-9219e558d71b"
  tenant_id       = "fb2513c3-cc7e-4238-9f99-6c936f62e2db"
}

module "network" {
  source   = "../../modules/network"
  project  = var.project
  location = var.location
}

module "monitoring" {
  source      = "../../modules/monitoring"
  project     = var.project
  location    = var.location
  rg_name     = module.network.rg_name
  alert_email = var.alert_email
  depends_on  = [module.network]
}

module "data" {
  source         = "../../modules/data"
  project        = var.project
  location       = var.location
  rg_name        = module.network.rg_name
  pg_db_name     = var.pg_db_name
  pg_sku_name    = var.pg_sku_name
  pg_storage_mb  = var.pg_storage_mb
  pg_backup_days = var.pg_backup_days
  law_id         = module.monitoring.law_id
  operator_ip    = var.operator_ip
  depends_on = [
    module.network,
    module.monitoring
  ]
}

module "keyvault" {
  source           = "../../modules/keyvault"
  location         = var.location
  project          = var.project
  rg_name          = module.network.rg_name
  operator_ip      = var.operator_ip
  kv_sku           = var.kv_sku
  kv_purge_protect = var.kv_purge_protect
  db_conn_str      = module.data.connection_string
  depends_on = [
    module.network,
    module.data
  ]
}

module "compute" {
  source          = "../../modules/compute"
  project         = var.project
  location        = var.location
  rg_name         = module.network.rg_name
  law_id          = module.monitoring.law_id
  action_group_id = module.monitoring.action_group_id
  kv_id           = module.keyvault.kv_id
  kv_secret_uri   = module.keyvault.db_conn_secret_uri
  container_image = var.container_image
  container_tag   = var.container_tag
  container_port  = var.container_port
  instance_count  = var.instance_count
  depends_on      = [module.keyvault]
}

