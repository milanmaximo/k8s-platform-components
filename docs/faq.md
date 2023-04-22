# Frequently Asked Questions

## Installation

### Which Kubernetes versions are supported?

Kubernetes 1.26 and 1.27 are fully tested and supported. Earlier versions may work but are not officially supported.

### Do I need Helm installed?

No, Helm is not required on your local machine. The repository uses Helm charts but Kustomize applies them directly.

## Deployment

### Can I use this in production?

Yes, all components are production-ready with:
- High availability configurations
- Resource limits defined
- Security best practices applied

### How do I upgrade component versions?

Update the version numbers in `helm/*/Chart.yaml` files and test in dev environment first.

## Troubleshooting

### Pods are not starting

Check:
1. Resource quotas in namespace
2. Image pull secrets
3. Pod logs: `kubectl logs <pod-name> -n <namespace>`

### Ingress not working

Verify:
1. Ingress controller is running
2. DNS records are configured
3. TLS certificates are valid
