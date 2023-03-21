# Security Guide

## Overview

Security best practices for platform components deployment.

## TLS/SSL Certificates

### Cert-Manager Configuration

All TLS certificates are managed by cert-manager with Let's Encrypt.

**Production issuer** uses ACME production server:
```yaml
server: https://acme-v02.api.letsencrypt.org/directory
```

**Staging issuer** for testing (to avoid rate limits):
```yaml
server: https://acme-staging-v02.api.letsencrypt.org/directory
```

### Certificate Management

1. **Automatic renewal**: Cert-manager renews certificates 30 days before expiry
2. **Challenge type**: HTTP-01 challenge through ingress-nginx
3. **Rate limits**: Let's Encrypt production has strict rate limits (50 certs/week)

### Creating Certificates

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-tls
  namespace: default
spec:
  secretName: example-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - example.com
    - www.example.com
```

## Vault Secrets Management

### Initialization

After deploying Vault, initialize and unseal:

```bash
# Initialize Vault
kubectl exec -n vault vault-0 -- vault operator init

# Save the unseal keys and root token securely!

# Unseal Vault (requires 3 out of 5 keys by default)
kubectl exec -n vault vault-0 -- vault operator unseal <key1>
kubectl exec -n vault vault-0 -- vault operator unseal <key2>
kubectl exec -n vault vault-0 -- vault operator unseal <key3>
```

### Enable Kubernetes Auth

```bash
# Login with root token
kubectl exec -n vault vault-0 -- vault login <root-token>

# Enable Kubernetes authentication
kubectl exec -n vault vault-0 -- vault auth enable kubernetes

# Configure Kubernetes auth
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
```

### Store Secrets

```bash
# Enable KV secrets engine
kubectl exec -n vault vault-0 -- vault secrets enable -path=secret kv-v2

# Write a secret
kubectl exec -n vault vault-0 -- vault kv put secret/myapp/config \
  username='admin' \
  password='supersecret'
```

### Inject Secrets into Pods

Use Vault Agent Injector:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "myapp"
    vault.hashicorp.com/agent-inject-secret-config: "secret/data/myapp/config"
spec:
  serviceAccountName: myapp
  containers:
    - name: app
      image: myapp:latest
```

## Network Security

### Ingress-NGINX Security Headers

Configure security headers in ingress-nginx:

```yaml
controller:
  config:
    # Force HTTPS
    force-ssl-redirect: "true"

    # Security headers
    add-headers: "ingress-nginx/custom-headers"

    # Hide version
    server-tokens: "false"

    # HSTS
    hsts: "true"
    hsts-max-age: "31536000"
    hsts-include-subdomains: "true"
```

**Custom headers ConfigMap**:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-headers
  namespace: ingress-nginx
data:
  X-Frame-Options: "SAMEORIGIN"
  X-Content-Type-Options: "nosniff"
  X-XSS-Protection: "1; mode=block"
  Referrer-Policy: "strict-origin-when-cross-origin"
  Content-Security-Policy: "default-src 'self'"
```

### Rate Limiting

Protect against DDoS with rate limiting:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/limit-rps: "10"
    nginx.ingress.kubernetes.io/limit-burst-multiplier: "5"
```

## RBAC

### Service Account Permissions

Minimal RBAC for external-dns:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
rules:
  - apiGroups: [""]
    resources: ["services","endpoints","pods"]
    verbs: ["get","watch","list"]
  - apiGroups: ["extensions","networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get","watch","list"]
```

## Secret Management

### External-DNS Credentials

Store DNS provider credentials in Kubernetes secrets:

```bash
kubectl create secret generic cloudflare-api-token \
  --from-literal=token=YOUR_TOKEN \
  --namespace external-dns
```

### Vault Auto-Unseal

For production, use auto-unseal with cloud KMS:

```yaml
seal "awskms" {
  region     = "eu-central-1"
  kms_key_id = "alias/vault-unseal"
}
```

## Security Scanning

### Scan Helm Charts

Use tools like `trivy` or `checkov`:

```bash
# Scan Helm values
trivy config helm/

# Check for misconfigurations
checkov -d helm/
```

### Image Scanning

Scan container images before deployment:

```bash
trivy image bitnami/nginx-ingress-controller:1.6.4
```

## Audit Logging

### Enable Vault Audit Logs

```bash
kubectl exec -n vault vault-0 -- vault audit enable file file_path=/vault/logs/audit.log
```

## Best Practices

1. **Never commit secrets** to Git (use `.gitignore`)
2. **Rotate credentials** regularly
3. **Use network policies** to restrict traffic
4. **Enable pod security policies/standards**
5. **Monitor and alert** on security events
6. **Regular updates** of all components
7. **Backup Vault data** and unseal keys securely
8. **Use staging ACME server** for testing
9. **Implement rate limiting** on public endpoints
10. **Review RBAC permissions** regularly
