#!/bin/bash
# Deploy platform components to Kubernetes cluster

set -e

ENVIRONMENT=${1:-dev}

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
  echo "Usage: $0 [dev|staging|prod]"
  exit 1
fi

echo "Deploying platform components to $ENVIRONMENT environment..."

# Check prerequisites
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "helm is required but not installed"; exit 1; }

# Add Helm repositories
echo "Adding Helm repositories..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Deploy with Kustomize
echo "Deploying with Kustomize..."
kubectl apply -k kustomize/$ENVIRONMENT

echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s \
  deployment -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

kubectl wait --for=condition=available --timeout=300s \
  deployment -n cert-manager -l app=cert-manager

echo "Deployment complete!"
echo ""
echo "Verify with:"
echo "  kubectl get pods -n ingress-nginx"
echo "  kubectl get pods -n cert-manager"
echo "  kubectl get pods -n external-dns"
echo "  kubectl get pods -n vault"
