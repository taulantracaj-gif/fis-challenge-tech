# Node.js Application Deployment with Helm and Terraform

This repository contains a complete solution for deploying a Node.js application to Azure Kubernetes Service (AKS) using Helm charts and Terraform infrastructure as code. The solution provides automated deployment, scaling, and ingress configuration with Azure Application Gateway integration.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Helm Chart Components](#helm-chart-components)
5. [Terraform Configuration](#terraform-configuration)
6. [Terragrunt Setup](#terragrunt-setup)
7. [Configuration](#configuration)
8. [Deployment](#deployment)
9. [Application Features](#application-features)
10. [Monitoring and Scaling](#monitoring-and-scaling)
11. [Security](#security)
12. [Customization](#customization)
13. [Troubleshooting](#troubleshooting)
14. [Best Practices](#best-practices)

## Overview

This solution combines the power of Helm for Kubernetes application packaging and Terraform for infrastructure management to deploy a Node.js application with:

- **Containerized Application**: Node.js app running in Docker containers
- **Auto-scaling**: Horizontal Pod Autoscaler (HPA) based on CPU/Memory
- **Load Balancing**: Azure Application Gateway with SSL termination
- **Service Discovery**: Kubernetes services and ingress
- **Configuration Management**: Environment variables and ConfigMaps
- **Health Checks**: Liveness and readiness probes


## Prerequisites

### Software Requirements
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [Helm](https://helm.sh/docs/intro/install/) >= 3.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.0
- [Docker](https://docs.docker.com/get-docker/) (for building images)

### Azure Requirements
- Azure subscription with AKS cluster deployed
- Azure Container Registry (ACR) for storing Docker images
- Application Gateway with SSL certificate configured
- DNS zone configuration for custom domain

### Access Requirements
- AKS cluster admin access
- ACR push/pull permissions
- Application Gateway configuration access
- DNS management permissions

## Project Structure

```
.
├── nodeapp/                           # Helm chart directory
│   ├── Chart.yaml                     # Chart metadata
│   ├── values.yaml                    # Default values
│   ├── .helmignore                    # Helm ignore patterns
│   └── templates/                     # Kubernetes manifests
│       ├── _helpers.tpl               # Template helpers
│       ├── deployment.yaml            # Pod deployment
│       ├── service.yaml               # Service definition
│       ├── ingress.yaml               # Ingress configuration
│       ├── hpa.yaml                   # Horizontal Pod Autoscaler
├── terraform/                         # Terraform configuration
│   ├── main.tf                        # Helm release resource
│   ├── variables.tf                   # Input variables
│   ├── provider-helm.tf               # Helm provider config
│   └── helm_values/                   # Custom values files
│       └── custom_values.yml          # Environment-specific values
└── terragrunt/                        # Terragrunt configuration
    ├── root.hcl                       # Root configuration
    └── tr-subscr-helm/                # Environment directory
        ├── env.hcl                    # Environment variables
        └── terragrunt.hcl             # Environment config
```

## Helm Chart Components

### Chart Metadata (`Chart.yaml`)
- **Chart Name**: nodeapp
- **Version**: 0.1.0 (chart version)
- **App Version**: 1.16.0 (application version)
- **Type**: application

### Core Kubernetes Resources

#### Deployment (`deployment.yaml`)
- **Container Image**: `testtr.azurecr.io/nodeapp`
- **Port**: 3000 (Node.js application port)
- **Environment Variables**: Configurable via values
- **Health Checks**: HTTP-based liveness and readiness probes
- **Security Context**: Configurable pod and container security
- **Resource Limits**: CPU and memory constraints

#### Service (`service.yaml`)
- **Type**: ClusterIP (internal access)
- **Port Mapping**: 80 → 3000
- **Selector**: Matches deployment pods
- **Protocol**: TCP/HTTP

#### Ingress (`ingress.yaml`)
- **Ingress Class**: azure-application-gateway
- **SSL Configuration**: Azure Application Gateway certificate
- **Host**: nodeapp.wildcard.mk
- **Path**: / (root path)
- **SSL Redirect**: Automatic HTTP to HTTPS

#### HPA (`hpa.yaml`)
- **API Version**: autoscaling/v2
- **Scaling Range**: 1-5 replicas
- **CPU Target**: 80% utilization
- **Memory Target**: 70% utilization
- **Scale Down Policy**: Stabilized with 5-minute window

### Template Helpers (`_helpers.tpl`)
- **Name Generation**: Consistent resource naming
- **Label Management**: Standard Kubernetes labels
- **Selector Logic**: Pod selection templates
- **Chart Information**: Version and metadata helpers

## Terraform Configuration

### Helm Provider Setup (`provider-helm.tf`)
The Terraform configuration uses the Helm provider to deploy charts to AKS:

```hcl
provider "helm" {
  alias = "aks"
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks_azure.kube_admin_config.0.host
    client_certificate     = base64decode(...)
    client_key             = base64decode(...)
    cluster_ca_certificate = base64decode(...)
  }
}
```

### Main Resource (`main.tf`)
The `helm_release` resource deploys the Node.js application:

```hcl
resource "helm_release" "nodeapp" {
  name      = "nodeapp"
  provider  = helm.aks
  chart     = "path/to/nodeapp/chart"
  namespace = var.namespace
  
  # Dynamic value injection
  set {
    name  = "image.repository"
    value = var.docker_image_repository
  }
  # Additional set blocks for configuration
}
```

### Key Configuration Options

#### Application Settings
- **Image Repository**: Container registry path
- **Image Tag**: Version/tag for deployment
- **Replica Count**: Initial number of pods
- **Environment Variables**: APP_NAME, ENVIRONMENT

#### Scaling Configuration
- **Auto-scaling**: Enabled by default
- **Min Replicas**: 1 (configurable)
- **Max Replicas**: 5 (configurable)
- **CPU Threshold**: 80% (configurable)
- **Memory Threshold**: 70% (configurable)

#### Network Configuration
- **Hostname**: Configurable subdomain prefix
- **Domain**: Base domain (wildcard.mk)
- **SSL Certificate**: Azure Application Gateway cert
- **Node Selector**: Target specific node pools

## Terragrunt Setup

### What is Terragrunt in This Context?

Terragrunt simplifies the Helm deployment by:
- **Provider Management**: Auto-generates Terraform providers
- **State Management**: Configures remote state in Azure Storage
- **Environment Separation**: Isolates configurations per environment
- **Variable Injection**: Passes environment-specific values

### Root Configuration (`root.hcl`)

The root configuration defines:
- **Provider Generation**: Azure, Helm, and Kubernetes providers
- **Version Constraints**: Terraform and provider versions
- **Remote State**: Azure Storage backend configuration
- **Common Logic**: Subscription and naming conventions

### Environment Configuration

#### Environment Variables (`env.hcl`)
```hcl
locals {
    subscription_id            = "your-subscription-id"
    state_resource_group_name  = "storage-resource-group"
    state_storage_account_name = "storage-account-name"
    state_container_name       = "terraform-state"
    environment                = "test"
    resource_group_name        = "aks-resource-group"
    cluster_name              = "aks-cluster-name"
}
```

#### Deployment Configuration (`terragrunt.hcl`)
- **Source Path**: Points to Terraform configuration
- **Input Variables**: Environment-specific values
- **Dependencies**: External resource dependencies

## Configuration

### Helm Values Configuration

#### Default Values (`values.yaml`)
```yaml
replicaCount: 1
image:
  repository: testtr.azurecr.io/nodeapp
  tag: ""
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 3000

ingress:
  enabled: true
  className: "azure-application-gateway"
  hosts:
    - host: nodeapp.wildcard.mk
      paths:
        - path: /
          pathType: Prefix

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 70
```

#### Custom Values (`custom_values.yml`)
```yaml
ingress:
  annotations:
    appgw.ingress.kubernetes.io/appgw-ssl-certificate: wildcardcert
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
```

### Terraform Variables

Key variables that can be customized:
- `namespace`: Kubernetes namespace for deployment
- `docker_image_repository`: Container registry URL
- `image_tag`: Application version to deploy
- `replica_count`: Initial number of replicas
- `hostname_prefix`: Subdomain for the application
- `node_selector_value`: Target node pool selector

## Deployment

### Using Terragrunt (Recommended)

1. **Navigate to environment directory**:
   ```bash
   cd terragrunt/tr-subscr-helm
   ```

2. **Validate configuration**:
   ```bash
   terragrunt validate
   terragrunt plan
   ```

3. **Deploy the application**:
   ```bash
   terragrunt apply
   ```

4. **Verify deployment**:
   ```bash
   kubectl get pods -n fis-test
   kubectl get ingress -n fis-test
   ```

### Using Helm Directly

1. **Deploy from local chart**:
   ```bash
   helm install nodeapp ./nodeapp \
     --namespace fis-test \
     --create-namespace \
     --set image.tag=v1.0.0
   ```

2. **Upgrade deployment**:
   ```bash
   helm upgrade nodeapp ./nodeapp \
     --namespace fis-test \
     --set image.tag=v1.1.0
   ```

### Using Terraform Directly

1. **Initialize providers**:
   ```bash
   cd terraform
   terraform init
   ```

2. **Create variable file**:
   ```bash
   cat > terraform.tfvars << EOF
   resource_group_name = "your-aks-rg"
   cluster_name = "your-aks-cluster"
   image_tag = "v1.0.0"
   EOF
   ```

3. **Deploy**:
   ```bash
   terraform plan
   terraform apply
   ```

## Application Features

### Health Monitoring
- **Liveness Probe**: HTTP GET to `/` endpoint
- **Readiness Probe**: HTTP GET to `/` endpoint
- **Startup Time**: Configurable probe delays
- **Failure Threshold**: Automatic pod restart on failures

### Auto-scaling
- **Metrics-based**: CPU and memory utilization
- **Scale-up**: Quick response to load increases
- **Scale-down**: Gradual with stabilization window
- **Resource Limits**: Prevents resource exhaustion

### Security Features
- **Service Account**: Dedicated Kubernetes identity
- **Network Policies**: Traffic isolation (if configured)
- **Image Pull Secrets**: Private registry authentication
- **Security Context**: Pod and container security settings

### Environment Configuration
- **Environment Variables**: Runtime configuration
- **ConfigMaps**: External configuration (extensible)
- **Secrets**: Sensitive data management (extensible)
- **Volume Mounts**: Persistent storage (configurable)

## Monitoring and Scaling

### Scaling Behavior
```yaml
behavior:
  scaleDown:
    stabilizationWindowSeconds: 300
    policies:
    - type: Pods
      value: 1
      periodSeconds: 60
```

### Resource Management
```yaml
resources:
  limits:
    cpu: "500m"
    memory: "1Gi"
  requests:
    cpu: "100m"
    memory: "256Mi"
```

### Monitoring Integration
- **Prometheus Metrics**: Application metrics (configurable)
- **Azure Monitor**: Container insights integration
- **Log Analytics**: Centralized logging
- **Application Insights**: APM integration (configurable)

## Security

### Pod Security
- **Security Context**: Non-root user execution
- **Read-only Root Filesystem**: Enhanced security

### Network Security
- **Ingress TLS**: SSL/TLS termination at gateway
- **Private Registry**: Secure image storage

### Access Control
- **RBAC**: Kubernetes role-based access control
- **Service Account**: Minimal required permissions
- **Azure AD Integration**: Enterprise identity management

## Customization

### Adding Environment Variables
Update the Helm values or Terraform configuration:

```yaml
# In values.yaml
env:
  APP_NAME: "nodeapp"
  ENVIRONMENT: "production"
  DATABASE_URL: "postgres://..."
  REDIS_URL: "redis://..."
```

### Custom Health Check Paths
Modify the probe configurations:

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: http
readinessProbe:
  httpGet:
    path: /health/ready
    port: http
```

### Multiple Ingress Hosts
Add additional hosts to the ingress configuration:

```yaml
hosts:
  - host: nodeapp.wildcard.mk
    paths:
      - path: /
        pathType: Prefix
  - host: api.wildcard.mk
    paths:
      - path: /api
        pathType: Prefix
```

### Custom Node Selection
Target specific node pools:

```yaml
nodeSelector:
  kubernetes.io/os: linux
  node-pool: application-pool
```

### Resource Scaling Policies
Customize HPA behavior:

```yaml
behavior:
  scaleUp:
    stabilizationWindowSeconds: 60
    policies:
    - type: Pods
      value: 2
      periodSeconds: 30
  scaleDown:
    stabilizationWindowSeconds: 300
    policies:
    - type: Pods
      value: 1
      periodSeconds: 60
```

## Troubleshooting

### Common Deployment Issues

#### Pod Startup Failures
```bash
# Check pod status
kubectl get pods -n fis-test
kubectl describe pod <pod-name> -n fis-test

# Check logs
kubectl logs <pod-name> -n fis-test
```

#### Image Pull Errors
```bash
# Verify image exists
az acr repository list --name testtr
az acr repository show-tags --name testtr --repository nodeapp

# Check pull secrets
kubectl get secrets -n fis-test
kubectl describe secret <image-pull-secret> -n fis-test
```

#### Ingress Configuration Issues
```bash
# Check ingress status
kubectl get ingress -n fis-test
kubectl describe ingress nodeapp -n fis-test

# Verify Application Gateway
az network application-gateway show --name <appgw-name> --resource-group <rg>
```

#### HPA Not Scaling
```bash
# Check HPA status
kubectl get hpa -n fis-test
kubectl describe hpa nodeapp -n fis-test

# Verify metrics server
kubectl top pods -n fis-test
kubectl get pods -n kube-system | grep metrics-server
```

#### Service Connectivity
```bash
# Port forward for testing
kubectl port-forward svc/nodeapp 8080:80 -n fis-test

# Test service internally
kubectl exec -it <pod-name> -n fis-test -- wget -qO- http://nodeapp.fis-test.svc.cluster.local
```

### Terraform/Terragrunt Issues

#### State Lock Issues
```bash
# Force unlock (use carefully)
terragrunt force-unlock <lock-id>

# Check state status
terragrunt state list
```

#### Provider Authentication
```bash
# Verify Azure authentication
az account show
az aks get-credentials --name <cluster-name> --resource-group <rg>

# Test kubectl connectivity
kubectl cluster-info
```

### Helm Issues

#### Chart Validation
```bash
# Validate templates
helm template nodeapp ./nodeapp --debug

# Lint chart
helm lint ./nodeapp

# Dry run installation
helm install nodeapp ./nodeapp --dry-run --debug
```

#### Release Management
```bash
# List releases
helm list -n fis-test

# Check release history
helm history nodeapp -n fis-test

# Rollback if needed
helm rollback nodeapp 1 -n fis-test
```

## Best Practices

### Infrastructure Best Practices
1. **State Management**: Use remote state with locking
2. **Module Versioning**: Pin provider and module versions
3. **Code Review**: Review all infrastructure changes
4. **Documentation**: Maintain up-to-date documentation

---
