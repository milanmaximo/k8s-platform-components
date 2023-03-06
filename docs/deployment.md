# Deployment Guide

## Prerequisites

- Kubernetes 1.26+
- Helm 3.11+
- kubectl configured
- kustomize (optional, kubectl has built-in support)

## Deploy with Helm

### Install individual components

```bash
# Add Helm repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Install ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  -f helm/ingress-nginx/values.yaml

# Install cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  -f helm/cert-manager/values.yaml

kubectl apply -f helm/cert-manager/clusterissuer.yaml

# Install external-dns
kubectl create secret generic cloudflare-api-token \
  --from-literal=token=YOUR_TOKEN \
  --namespace external-dns

helm install external-dns external-dns/external-dns \
  --namespace external-dns --create-namespace \
  -f helm/external-dns/values.yaml

# Install Vault
helm install vault hashicorp/vault \
  --namespace vault --create-namespace \
  -f helm/vault/values.yaml
```

## Deploy with Kustomize

### Development environment

```bash
kubectl apply -k kustomize/dev
```

### Staging environment

```bash
kubectl apply -k kustomize/staging
```

### Production environment

```bash
kubectl apply -k kustomize/prod
```

## Post-installation

### Initialize Vault

```bash
kubectl exec -n vault vault-0 -- vault operator init
kubectl exec -n vault vault-0 -- vault operator unseal
```

### Verify installations

```bash
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
kubectl get pods -n external-dns
kubectl get pods -n vault
```

### Test cert-manager

```bash
kubectl get clusterissuers
kubectl describe clusterissuer letsencrypt-prod
```

## Troubleshooting

### Check logs

```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
kubectl logs -n cert-manager -l app=cert-manager
kubectl logs -n external-dns -l app.kubernetes.io/name=external-dns
kubectl logs -n vault -l app.kubernetes.io/name=vault
```

### Common issues

- **Cert-manager webhook timeout**: Wait 60 seconds after installation
- **External-DNS not updating**: Check API token and domain filters
- **Vault sealed**: Run unseal command with keys from init
