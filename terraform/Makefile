# Terraform Makefile
# Usage: make check|plan|apply|destroy ENV=poc|dev|uat|prod

.PHONY: fmt tflint trivy check plan apply plan-destroy destroy healthcheck diagram-graph help

# --- Checks ---
fmt:
ifeq ($(ENV),)
	terraform fmt -recursive modules tests || true
else
	terraform fmt -recursive environments/$(ENV) modules tests || true
endif

tflint:
ifeq ($(ENV),)
	tflint --chdir=modules
	tflint --chdir=tests || true
else
	tflint --chdir=environments/$(ENV)
	tflint --chdir=modules
	tflint --chdir=tests || true
endif

trivy:
ifeq ($(ENV),)
	trivy config modules
	trivy config tests || true
else
	trivy config --tf-vars environments/$(ENV)/$(ENV).tfvars environments/$(ENV)
	trivy config modules
	trivy config tests || true
endif

# --- Validate ---
check:
ifeq ($(ENV),)
	$(error ENV not set. Use: make check ENV=poc|dev|uat|prod)
endif
	@echo ">>> Checking ENV=$(ENV)"
	$(MAKE) fmt ENV=$(ENV)
	$(MAKE) tflint ENV=$(ENV)
	$(MAKE) trivy ENV=$(ENV)
	terraform -chdir=environments/$(ENV) init -backend=false -upgrade=false -reconfigure
	terraform -chdir=environments/$(ENV) validate

# --- Plan ---
plan:
ifeq ($(ENV),)
	$(error ENV not set. Use: make plan ENV=poc|dev|uat|prod)
endif
	@if [ ! -f environments/$(ENV)/$(ENV).tfvars ]; then \
		echo "Missing: environments/$(ENV)/$(ENV).tfvars"; exit 1; fi
	@echo ">>> Planning ENV=$(ENV)"
	terraform -chdir=environments/$(ENV) init --reconfigure
	terraform -chdir=environments/$(ENV) plan -var-file=$(ENV).tfvars -out=$(ENV).tfplan
	terraform -chdir=environments/$(ENV) show -json $(ENV).tfplan > $(ENV).tfplan.json

# --- Apply ---
apply:
ifeq ($(ENV),)
	$(error ENV not set. Use: make apply ENV=poc|dev|uat|prod)
endif
	@if [ ! -f environments/$(ENV)/$(ENV).tfplan ]; then \
	  echo "Missing tfplan. Run: make plan ENV=$(ENV)"; exit 1; fi
	@echo ">>> Applying ENV=$(ENV)"
	terraform -chdir=environments/$(ENV) apply -auto-approve $(ENV).tfplan

# --- Destroy ---
plan-destroy:
ifeq ($(ENV),)
	$(error ENV not set. Use: make destroy ENV=poc|dev|uat|prod)
endif
	if [ ! -f environments/$(ENV)/$(ENV).tfvars ]; then \
	  echo "Missing: environments/$(ENV)/$(ENV).tfvars"; exit 1; fi
	@echo ">>> Planning destroy ENV=$(ENV)"
	terraform -chdir=environments/$(ENV) init --reconfigure
	terraform -chdir=environments/$(ENV) plan -destroy -var-file=$(ENV).tfvars -out=$(ENV).tfplan-destroy
	terraform -chdir=environments/$(ENV) show -json $(ENV).tfplan-destroy > $(ENV).tfplan-destroy.json
	
destroy:
ifeq ($(ENV),)
	$(error ENV not set. Use: make destroy ENV=poc|dev|uat|prod)
endif
	@echo ">>> Destroying ENV=$(ENV)"
	terraform -chdir=environments/$(ENV) destroy -auto-approve -var-file=$(ENV).tfvars

# --- Health check ---
healthcheck:
ifeq ($(ENV),)
	$(error ENV not set. Use: make health ENV=poc|dev|uat|prod)
endif
	@echo ">>> Running healthcheck ENV=$(ENV)"
	API_URL=$$(terraform -chdir=environments/$(ENV) output -raw quote_url) \
	DB_HOST=$$(terraform -chdir=environments/$(ENV) output -raw db_host) \
	DB_USER=$$(terraform -chdir=environments/$(ENV) output -raw db_user) \
	DB_PASS=$$(terraform -chdir=environments/$(ENV) output -raw db_pass) \
	DB_NAME=$$(terraform -chdir=environments/$(ENV) output -raw db_name) \
	./tests/healthcheck.sh

# --- Graph ---
diagram-graph:
ifeq ($(ENV),)
        $(error ENV not set. Use: make health ENV=poc|dev|uat|prod)
endif
	@echo ">>> Generating diagram_$(ENV).png"
	terraform -chdir=environments/$(ENV) plan -var-file=$(ENV).tfvars -out=$(ENV).tfplan.bin
	terraform -chdir=environments/$(ENV) graph -plan=$(ENV).tfplan.bin | dot -Tpng -o diagram_$(ENV).png


# --- Help ---
help:
	@echo "Targets:"
	@echo "  make fmt                      # format all Terraform code"
	@echo "  make tflint                   # lint environments/ and modules/"
	@echo "  make trivy                    # IaC security scan through Trivy"
	@echo "  make check   ENV=<env>        # fmt+tflint+trivy+validate"
	@echo "  make plan    ENV=<env>        # init+plan"
	@echo "  make apply   ENV=<env>        # apply tfplan"
	@echo "  make plan-destroy   ENV=<env> # plan destroy"
	@echo "  make destroy ENV=<env>        # destroy resources"
	@echo "  make healthcheck ENV=<env>    # Run healthcheck on API and Postgres db"
	@echo ""
	@echo "environment dir: environments/<env>/   | var file: environments/<env>/<env>.tfvars"
	@echo "Usage Example: make check ENV=poc"

