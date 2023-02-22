# Kubernetes Platform Components

Reusable Kubernetes platform components for multi-environment deployments.

## Components

- **ingress-nginx**: NGINX Ingress Controller
- **cert-manager**: Automated TLS certificate management
- **external-dns**: Automatic DNS record management
- **vault**: Secrets management

## Requirements

- Kubernetes 1.26+
- Helm 3.11+
- kubectl

## Structure

```
.
├── helm/              # Helm values for each component
├── kustomize/         # Kustomize overlays per environment
└── docs/              # Documentation
```

## License

MIT
