variable "project" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "operator_ip" { type = string }
variable "kv_sku" { type = string }
variable "kv_purge_protect" { type = bool }
variable "db_conn_str" {
  type      = string
  sensitive = true
}
