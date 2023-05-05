.PHONY: help validate lint test deploy-dev deploy-staging deploy-prod clean

ENVIRONMENT ?= dev

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

validate: ## Validate YAML files with yamllint
	@echo "Validating YAML files..."
	@yamllint -c .yamllint helm/ kustomize/

lint: ## Lint Helm charts
	@echo "Linting Helm charts..."
	@helm lint helm/ingress-nginx/ || true
	@helm lint helm/cert-manager/ || true
	@helm lint helm/external-dns/ || true
	@helm lint helm/vault/ || true

test: validate ## Run all tests (validate + kustomize build)
	@echo "Testing Kustomize builds..."
	@kubectl kustomize kustomize/dev > /dev/null && echo "✓ dev build OK"
	@kubectl kustomize kustomize/staging > /dev/null && echo "✓ staging build OK"
	@kubectl kustomize kustomize/prod > /dev/null && echo "✓ prod build OK"

deploy-dev: ## Deploy to dev environment
	@echo "Deploying to dev environment..."
	@./scripts/deploy.sh dev

deploy-staging: ## Deploy to staging environment
	@echo "Deploying to staging environment..."
	@./scripts/deploy.sh staging

deploy-prod: ## Deploy to production environment
	@echo "Deploying to production environment..."
	@./scripts/deploy.sh prod

undeploy: ## Remove deployment from environment (use ENVIRONMENT=dev|staging|prod)
	@echo "Removing deployment from $(ENVIRONMENT)..."
	@./scripts/uninstall.sh $(ENVIRONMENT)

helm-repos: ## Add all required Helm repositories
	@echo "Adding Helm repositories..."
	@helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	@helm repo add jetstack https://charts.jetstack.io
	@helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
	@helm repo add hashicorp https://helm.releases.hashicorp.com
	@helm repo update

verify: ## Verify all components are running
	@echo "Verifying components..."
	@kubectl get pods -n ingress-nginx
	@kubectl get pods -n cert-manager
	@kubectl get pods -n external-dns
	@kubectl get pods -n vault

logs-ingress: ## Show ingress-nginx logs
	@kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --tail=100 -f

logs-certmanager: ## Show cert-manager logs
	@kubectl logs -n cert-manager -l app=cert-manager --tail=100 -f

logs-externaldns: ## Show external-dns logs
	@kubectl logs -n external-dns -l app.kubernetes.io/name=external-dns --tail=100 -f

logs-vault: ## Show vault logs
	@kubectl logs -n vault -l app.kubernetes.io/name=vault --tail=100 -f

clean: ## Clean up Kind cluster (if used for testing)
	@echo "Cleaning up..."
	@kind delete cluster --name platform-test 2>/dev/null || true
