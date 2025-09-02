# **Project:  Terriaform_QuoteAPI**

**Deploys: https://github.com/pbgnz/random-quote-api with minor modification to run as non-root user.
Modified Dockerimage: bbhbdb/qapi:secure**

**Prerequisites:**
- Azure subscription
- Azure CLI 
- Terraform ≥ 1.6

**Usage:**
  make fmt                      # format all Terraform code
  make tflint                   # lint environments/ and modules/
  make trivy                    # IaC security scan through Trivy
  make check   ENV=<env>        # fmt+tflint+trivy+validate
  make plan    ENV=<env>        # init+plan
  make apply   ENV=<env>        # apply tfplan
  make plan-destroy   ENV=<env> # plan destroy
  make destroy ENV=<env>        # destroy resources
  make healthcheck ENV=<env>    # Run healthcheck on API and Postgres db

environment dir: environments/<env>/   | var file: environments/<env>/<env>.tfvars
Usage Example: make check ENV=poc


**Cost Notes (Tentative):**
                                                                                                                      
 module.compute.azurerm_monitor_metric_alert.http5xx_count                                                            
 └─ Metrics monitoring                                      Monthly costs depends on usage: starts with $0.10   
                                                                                                                      
 module.monitoring.azurerm_log_analytics_workspace.law                                                                
 ├─ Log data ingestion                                      Monthly cost depends on usage: $3.34 per GB               
 ├─ Log data export                                         Monthly cost depends on usage: $0.14 per GB               
 ├─ Basic log data ingestion                                Monthly cost depends on usage: $0.70 per GB               
 ├─ Basic log search queries                                Monthly cost depends on usage: $0.007 per GB searched     
 ├─ Archive data                                            Monthly cost depends on usage: $0.028 per GB              
 ├─ Archive data restored                                   Monthly cost depends on usage: $0.14 per GB               
 └─ Archive data searched                                   Monthly cost depends on usage: $0.007 per GB              
                                                                                                                      
 module.monitoring.azurerm_monitor_action_group.ag                                                                    
 └─ Email notifications (1)                                 Monthly cost depends on usage: $0.00002 per emails

PostgreSQL Flexible Server: main ongoing cost driver. Size via var.pg_sku_name and var.pg_storage_mb.

Container Apps: billed by vCPU/memory + execution time.

Key Vault: billed per 10k operations.        
                                                                                                           

**ASD essential eight mapping:**
- Application control:
- Patching apps:
- Patching O/S: Azure maintains regular patching of container host and PostgreSQL
- MFA: Access to Azure has MFA enabed.
- Microsoft Office Macros: N/A
- Application user restrictions: Runs as non-root user (appuser)
- Privilege and access control: secrets maintained in Keyvault and access restricted
- Backups: PostgreSQL backups maintained.
