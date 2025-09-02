output "quote_url" {
  description = "Base URL for the Quote API"
  value       = "https://${module.compute.api_url}"
}

output "db_host" {
  description = "Postgres DB host"
  value       = module.data.db_host
}

output "db_user" {
  description = "Postgres DB username"
  value       = module.data.db_user
  sensitive   = true
}

output "db_pass" {
  description = "Postgres DB Password"
  value       = module.data.db_pass
  sensitive   = true
}

output "db_name" {
  description = "Postgres DB name"
  value       = module.data.db_name
}

