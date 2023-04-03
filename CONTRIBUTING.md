# Contributing Guide

## Development Workflow

### Prerequisites

Install required tools:
- kubectl 1.26+
- Helm 3.11+
- yamllint
- Docker (for local testing)

### Making Changes

1. Create a feature branch:
```bash
git checkout -b feature/my-feature
```

2. Make your changes to Helm values or Kustomize overlays

3. Validate YAML syntax:
```bash
yamllint helm/ kustomize/
```

4. Test Kustomize builds:
```bash
kustomize build kustomize/dev
kustomize build kustomize/staging
kustomize build kustomize/prod
```

5. Lint Helm charts (if applicable):
```bash
helm lint helm/ingress-nginx/
helm lint helm/cert-manager/
```

6. Commit changes:
```bash
git add .
git commit -m "Description of changes"
```

## Adding New Components

### Directory Structure

When adding a new component:

```
helm/my-component/
├── Chart.yaml          # Helm chart metadata
├── values.yaml         # Default values
└── README.md           # Component documentation
```

### Update Kustomize Base

Add the component to `kustomize/base/kustomization.yaml`:

```yaml
helmCharts:
  - name: my-component
    repo: https://charts.example.com
    version: 1.0.0
    releaseName: my-component
    namespace: my-component
    valuesFile: ../../helm/my-component/values.yaml
```

### Update Namespace

Add namespace to `kustomize/base/namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-component
```

## Testing

### Local Testing with Kind

```bash
# Create Kind cluster
kind create cluster --name platform-test

# Deploy components
kubectl apply -k kustomize/dev

# Verify
kubectl get pods --all-namespaces
```

### Cleanup

```bash
kind delete cluster --name platform-test
```

## Documentation

- Update README.md if adding new features
- Add component-specific documentation in docs/
- Include examples in examples/ directory
- Update deployment guide if necessary

## GitLab CI

All merge requests trigger:
- YAML validation
- Helm linting
- Kustomize build tests

Ensure all checks pass before merging.

## Version Compatibility

Maintain compatibility with:
- Kubernetes 1.26+
- Helm 3.11+

When updating component versions:
1. Test compatibility
2. Update Chart.yaml
3. Update README.md
4. Document breaking changes

## Commit Messages

Use descriptive commit messages:

```
Add monitoring configuration for external-dns

- Enable Prometheus metrics endpoint
- Add ServiceMonitor resource
- Configure scrape interval to 30s
```

## Code Review

All changes require:
- Passing CI checks
- Documentation updates
- One approval from maintainer

## Release Process

1. Update version in Chart.yaml files
2. Tag release: `git tag v1.0.0`
3. Push tag: `git push origin v1.0.0`
4. GitLab CI automatically creates release

## Getting Help

- Check documentation in docs/
- Review examples in examples/
- Open an issue for bugs or feature requests
