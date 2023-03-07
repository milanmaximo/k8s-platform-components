# Kubernetes Platform Components

Production-ready Kubernetes platform components for multi-environment deployments. This repository provides a standardized way to deploy and manage core infrastructure components across dev, staging, and production environments.

## Components

- **ingress-nginx** (v4.5.2): NGINX Ingress Controller for HTTP/HTTPS routing
- **cert-manager** (v1.11.0): Automated TLS certificate management with Let's Encrypt
- **external-dns** (v1.12.0): Automatic DNS record management for Kubernetes resources
- **vault** (v1.13.0): HashiCorp Vault for secrets management and encryption

## Features

- Multi-environment support (dev, staging, production)
- Kustomize overlays for environment-specific configuration
- GitLab CI/CD pipeline for automated validation and deployment
- Prometheus metrics enabled for all components
- High availability configurations for production
- Comprehensive documentation and deployment scripts

## Requirements

- Kubernetes 1.26+
- Helm 3.11+
- kubectl
- (Optional) kustomize CLI

## Quick Start

### Deploy all components to dev

```bash
./scripts/deploy.sh dev
```

### Deploy with kubectl and Kustomize

```bash
kubectl apply -k kustomize/dev
```

### Deploy individual components with Helm

See [deployment documentation](docs/deployment.md) for detailed instructions.

## Repository Structure

```
.
├── helm/                      # Helm values for each component
│   ├── ingress-nginx/
│   ├── cert-manager/
│   ├── external-dns/
│   └── vault/
├── kustomize/                 # Kustomize overlays per environment
│   ├── base/                  # Base configuration
│   ├── dev/                   # Development overlay
│   ├── staging/               # Staging overlay
│   └── prod/                  # Production overlay
├── scripts/                   # Automation scripts
│   ├── deploy.sh
│   └── uninstall.sh
└── docs/                      # Documentation
    ├── deployment.md
    └── monitoring.md
```

## Documentation

- [Deployment Guide](docs/deployment.md) - Installation and deployment instructions
- [Monitoring Guide](docs/monitoring.md) - Metrics, dashboards, and alerting

## Environment Differences

| Component | Dev | Staging | Production |
|-----------|-----|---------|------------|
| ingress-nginx replicas | 2 | 2 | 3 |
| cert-manager replicas | 1 | 1 | 2 |
| ACME server | staging | production | production |
| Resource requests | low | medium | high |

## CI/CD

GitLab CI pipeline includes:
- YAML validation with yamllint
- Helm chart linting
- Kustomize build tests
- Automated deployment to dev
- Manual promotion to staging/production

## License

MIT
