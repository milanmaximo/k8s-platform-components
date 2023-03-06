#!/bin/bash
# Uninstall platform components from Kubernetes cluster

set -e

ENVIRONMENT=${1:-dev}

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
  echo "Usage: $0 [dev|staging|prod]"
  exit 1
fi

echo "Uninstalling platform components from $ENVIRONMENT environment..."

kubectl delete -k kustomize/$ENVIRONMENT --ignore-not-found=true

echo "Uninstall complete!"
