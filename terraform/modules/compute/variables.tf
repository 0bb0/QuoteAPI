variable "project" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "law_id" { type = string }
variable "action_group_id" { type = string }
variable "kv_id" { type = string }
variable "kv_secret_uri" { type = string }

variable "container_image" { type = string }
variable "container_tag" { type = string }
variable "container_port" { type = number }
variable "instance_count" { type = number }

