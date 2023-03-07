# Monitoring Guide

## Prometheus Metrics

All platform components expose Prometheus metrics.

### Ingress-NGINX Metrics

Ingress-NGINX controller exposes metrics on port 10254.

**Endpoint**: `http://<controller-pod>:10254/metrics`

**Key metrics**:
- `nginx_ingress_controller_requests` - Total requests
- `nginx_ingress_controller_request_duration_seconds` - Request latency
- `nginx_ingress_controller_response_size` - Response size
- `nginx_ingress_controller_success` - Successful requests

**ServiceMonitor example**:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
  endpoints:
    - port: metrics
      interval: 30s
```

### Cert-Manager Metrics

Cert-manager exposes metrics on port 9402.

**Key metrics**:
- `certmanager_certificate_expiration_timestamp_seconds` - Certificate expiry time
- `certmanager_certificate_ready_status` - Certificate readiness
- `certmanager_acme_client_request_count` - ACME requests
- `certmanager_acme_client_request_duration_seconds` - ACME request duration

### Vault Metrics

Vault exposes metrics at `/v1/sys/metrics` endpoint.

**Key metrics**:
- `vault_core_unsealed` - Unseal status
- `vault_runtime_alloc_bytes` - Memory usage
- `vault_runtime_num_goroutines` - Active goroutines
- `vault_token_count` - Active tokens

## Grafana Dashboards

### Recommended Dashboards

1. **NGINX Ingress Controller** (ID: 9614)
   - Request rate
   - Success rate
   - Latency percentiles
   - Error rate

2. **Cert-Manager** (ID: 11001)
   - Certificate expiration
   - ACME challenge success rate
   - Issuer status

3. **Vault** (Community dashboards available)
   - Seal status
   - Token usage
   - Request rate
   - Cache hit ratio

## Alerting Rules

### Cert-Manager Alerts

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: cert-manager-alerts
  namespace: cert-manager
spec:
  groups:
    - name: cert-manager
      interval: 30s
      rules:
        - alert: CertificateExpiringSoon
          expr: certmanager_certificate_expiration_timestamp_seconds - time() < 604800
          for: 1h
          labels:
            severity: warning
          annotations:
            summary: "Certificate {{ $labels.name }} expiring soon"
            description: "Certificate expires in less than 7 days"

        - alert: CertificateNotReady
          expr: certmanager_certificate_ready_status == 0
          for: 10m
          labels:
            severity: critical
          annotations:
            summary: "Certificate {{ $labels.name }} not ready"
```

### Ingress-NGINX Alerts

```yaml
- alert: NginxHighErrorRate
  expr: rate(nginx_ingress_controller_requests{status=~"5.."}[5m]) > 0.05
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High 5xx error rate on ingress {{ $labels.ingress }}"
```

## Log Aggregation

### Loki Integration

Use Promtail to collect logs from all platform components:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: promtail-config
data:
  promtail.yaml: |
    server:
      http_listen_port: 9080

    positions:
      filename: /tmp/positions.yaml

    clients:
      - url: http://loki:3100/loki/api/v1/push

    scrape_configs:
      - job_name: kubernetes-pods
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_namespace]
            regex: (ingress-nginx|cert-manager|external-dns|vault)
            action: keep
```

## Health Checks

### Verify Component Health

```bash
# Ingress-NGINX
kubectl exec -n ingress-nginx <pod> -- curl -s localhost:10254/healthz

# Cert-Manager
kubectl get certificates --all-namespaces
kubectl describe certificate <name>

# External-DNS
kubectl logs -n external-dns -l app.kubernetes.io/name=external-dns

# Vault
kubectl exec -n vault vault-0 -- vault status
```
