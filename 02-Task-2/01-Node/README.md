# NodeJS Kubernetes Deployment

A Kubernetes deployment solution for NodeJS applications using Kustomize, supporting both local development (Minikube) and cloud deployment (Azure AKS). This project provides automated deployment scripts, Horizontal Pod Autoscaling (HPA), and flexible configuration management.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Project Structure](#project-structure)
5. [Configuration](#configuration)
6. [Deployment](#deployment)
7. [Monitoring and Scaling](#monitoring-and-scaling)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Configuration](#advanced-configuration)
10. [Azure Integration](#azure-integration)
11. [Best Practices](#best-practices)
---

## Overview

This project provides a Kubernetes deployment solution for NodeJS applications with the following features:

- **Automated Deployment**: PowerShell scripts for complete deployment workflow
- **Flexible Scaling**: Horizontal Pod Autoscaler with CPU and memory-based scaling
- **Environment Agnostic**: Supports both Minikube (local) and Azure AKS (cloud)
- **Kustomize Integration**: Template-based configuration management
- **NGINX Ingress**: HTTP routing and load balancing
- **Production Ready**: Security contexts, resource limits, and health checks

### Key Components

- **Deployment**: Application pods with configurable resources and replicas
- **Service**: Internal load balancing and service discovery
- **Ingress**: External HTTP/HTTPS access with NGINX
- **HPA**: Automatic scaling based on resource utilization
- **Scripts**: Automated provisioning and configuration management

---


### Traffic Flow

1. External traffic hits the **Ingress Controller** (NGINX)
2. Ingress routes traffic to the **Service**
3. Service load-balances to **NodeJS Pods**
4. **HPA** monitors resource usage and scales pods automatically

---

## Prerequisites

### Local Development (Minikube)

- [Minikube](https://minikube.sigs.k8s.io/docs/start/) v1.25+
- [kubectl](https://kubernetes.io/docs/tasks/tools/) v1.25+
- [Docker](https://docs.docker.com/get-docker/) v20.10+
- PowerShell 5.1+ or PowerShell Core 7+

### Azure Deployment

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) v2.30+
- Active Azure Subscription
- Azure Kubernetes Service (AKS) cluster
- kubectl configured for AKS access

### Initial Local Setup (Minikube)

```powershell
# Start Minikube
minikube start --memory=4096 --cpus=2

# Verify cluster status
kubectl get nodes

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify addons
kubectl get pods -n ingress-nginx
kubectl get pods -n kube-system | grep metrics-server

# Create application namespace
kubectl create namespace dev

# Configure Docker environment (if building locally)
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# Load Docker image into Minikube
minikube image load 01-node-app1:latest
```

---

## Quick Start

### 1. Clone and Navigate
```powershell
git clone <repository-url>
cd nodejs-kubernetes-deployment/01-NODE
```

### 2. Build Docker Image (if needed)
```powershell
# Build your NodeJS application
docker build -t 01-node-app1:latest .

# Load into Minikube
minikube image load 01-node-app1:latest
```

### 3. Deploy Application
```powershell
# Deploy with default settings
.\Provision\DeployAll.ps1 -Namespace dev -AppName nodejs-app

# Deploy with custom configuration
.\Provision\DeployAll.ps1 `
    -Namespace dev `
    -AppName nodejs-app `
    -MinReplicas 3 `
    -MaxReplicas 6 `
    -ImageName "01-node-app1" `
    -ImageTag "v1.0.0" `
    -RequestsCpu "200m" `
    -RequestsMemory "512Mi"
```

### 4. Verify Deployment
```powershell
# Check deployment status
kubectl get pods -l app=nodejs-app -n dev -o wide

# Check services
kubectl get services -n dev

# Check ingress
kubectl get ingress -n dev

# Check HPA status
kubectl get hpa -n dev
```

### 5. Access Application
```powershell
# Get Minikube IP
minikube ip

# Add to hosts file (Windows: C:\Windows\System32\drivers\etc\hosts)
# <minikube-ip> node.local

# Access application
curl http://node.local
# or visit http://node.local in browser
```

---

## Project Structure

```
01-NODE/
├── Deployment/           # Kubernetes Deployment manifests
│   ├── deploy.yaml       # Base deployment manifest
│   ├── kustomization.yaml # Kustomize configuration
│   ├── patch-deploy.yaml # Resource and environment patches
│   └── patch-deploy-replicas.yaml # Replica count patches
├── Service/              # Kubernetes Service manifests
│   ├── deploy.yaml       # Service definition
│   └── kustomization.yaml # Service kustomization
├── Ingress/              # Ingress Controller configuration
│   ├── deploy.yaml       # NGINX ingress rules
│   └── kustomization.yaml # Ingress kustomization
├── HPA/                  # Horizontal Pod Autoscaler
│   ├── deploy.yaml       # Base HPA configuration
│   ├── kustomization.yaml # HPA kustomization
│   ├── patch-nodejs-app-up-cpu.yaml    # CPU scale-up rules
│   ├── patch-nodejs-app-up-memory.yaml # Memory scale-up rules
│   └── patch-nodejs-app-down.yaml      # Scale-down rules
├── scripts/              # Automation scripts
│   ├── DeployToKubernetes.ps1          # Generic deployment script
│   ├── PatchDeploymentYaml.ps1         # Deployment patching
│   ├── PatchDeploymentKustomizationYaml.ps1 # Kustomization patching
│   ├── PatchDeploymentReplicasYaml.ps1 # Replica patching
│   └── PatchHpaYaml.ps1                # HPA patching
└── Provision/            # Orchestration scripts
    └── DeployAll.ps1     # Complete deployment workflow
```

### Folder Purpose Summary

| Folder | Purpose | Key Files |
|--------|---------|-----------|
| **Deployment** | Pod deployment configuration | `deploy.yaml`, patches for resources/replicas |
| **Service** | Internal load balancing | `deploy.yaml` with ClusterIP configuration |
| **Ingress** | External HTTP routing | NGINX ingress rules and SSL termination |
| **HPA** | Automatic scaling | CPU/Memory-based scaling policies |
| **scripts** | Automation utilities | PowerShell scripts for patching and deployment |
| **Provision** | Orchestration | End-to-end deployment workflow |

---

## Configuration

### Environment Variables

The deployment supports various configuration options through parameters:

#### Deployment Parameters
```powershell
$DeploymentParams = @{
    Namespace = "dev"                    # Kubernetes namespace
    AppName = "nodejs-app"               # Application name and labels
    ImageName = "01-node-app1"           # Docker image name
    ImageTag = "latest"                  # Docker image tag
    RequestsCpu = "100m"                 # CPU requests
    RequestsMemory = "256Mi"             # Memory requests
    LimitsCpu = "500m"                   # CPU limits
    LimitsMemory = "1Gi"                 # Memory limits
}
```

#### HPA Parameters
```powershell
$HPAParams = @{
    MinReplicas = 2                      # Minimum pods
    MaxReplicas = 4                      # Maximum pods
    ScaleUpCpuPercentage = 60            # CPU threshold for scaling up
    ScaleUpMemoryPercentage = 55         # Memory threshold for scaling up
    ScaleDownCpuPercentage = 35          # CPU threshold for scaling down
    ScaleDownMemoryPercentage = 30       # Memory threshold for scaling down
    ScaleUpStabilizationMinutes = 10     # Scale up stabilization window
    ScaleDownStabilizationMinutes = 20   # Scale down stabilization window
}
```

#### Cloud Parameters (Azure)
```powershell
$AzureParams = @{
    Subscription = "your-subscription-id"
    AksName = "your-aks-cluster"
    ResourceGroup = "your-resource-group"
    DeploymentType = "azure"
}
```

### Customizing Deployments

#### Resource Requirements
Modify resource requests and limits based on your application needs:

```yaml
# In patch-deploy.yaml
resources:
  requests:
    memory: "512Mi"    # Increase for memory-intensive apps
    cpu: "200m"        # Increase for CPU-intensive apps
  limits:
    memory: "2Gi"      # Set appropriate upper bounds
    cpu: "1000m"       # Prevent resource exhaustion
```

#### Scaling Configuration
Adjust HPA thresholds for optimal scaling behavior:

```yaml
# CPU-based scaling
averageUtilization: 70    # Scale up when CPU > 70%

# Memory-based scaling  
averageUtilization: 80    # Scale up when Memory > 80%

# Stabilization windows
stabilizationWindowSeconds: 300  # 5-minute window
```

---

## Deployment

### Manual Step-by-Step Deployment

#### 1. Patch Configuration Files
```powershell
# Update deployment configuration
.\scripts\PatchDeploymentYaml.ps1 `
    -DeploymentYamlFilePath ".\Deployment\patch-deploy.yaml" `
    -RequestsCpu "200m" -RequestsMemory "512Mi" `
    -LimitsCpu "1000m" -LimitsMemory "2Gi" `
    -AppName "nodejs-app" -Replicas 3

# Update image configuration
.\scripts\PatchDeploymentKustomizationYaml.ps1 `
    -KustomizationYamlFilePath ".\Deployment\kustomization.yaml" `
    -ImageName "01-node-app1" -ImageTag "v1.2.0"

# Update HPA configuration
.\scripts\PatchHpaYaml.ps1 `
    -CpuPatchFilePath ".\HPA\patch-nodejs-app-up-cpu.yaml" `
    -MemoryPatchFilePath ".\HPA\patch-nodejs-app-up-memory.yaml" `
    -DownPatchFilePath ".\HPA\patch-nodejs-app-down.yaml" `
    -MinReplicas 2 -MaxReplicas 6 `
    -ScaleUpCpuPercentage 70 -ScaleUpMemoryPercentage 75 `
    -ScaleDownCpuPercentage 30 -ScaleDownMemoryPercentage 25 `
    -ScaleUpStabilizationMinutes 5 -ScaleDownStabilizationMinutes 15
```

#### 2. Deploy Resources
```powershell
# Deploy in correct order
kubectl apply -k .\Deployment -n dev
kubectl apply -k .\Service -n dev
kubectl apply -k .\HPA -n dev
kubectl apply -k .\Ingress -n dev

# Verify deployments
kubectl get all -n dev
```

### Automated Deployment

#### Basic Deployment
```powershell
.\Provision\DeployAll.ps1 -Namespace dev -AppName nodejs-app
```

#### Production Deployment
```powershell
.\Provision\DeployAll.ps1 `
    -Namespace production `
    -AppName nodejs-app `
    -MinReplicas 3 `
    -MaxReplicas 10 `
    -ScaleUpCpuPercentage 60 `
    -ScaleUpMemoryPercentage 60 `
    -ScaleDownCpuPercentage 30 `
    -ScaleDownMemoryPercentage 30 `
    -ImageName "your-registry/nodejs-app" `
    -ImageTag "v2.1.0" `
    -RequestsCpu "500m" `
    -RequestsMemory "1Gi" `
    -LimitsCpu "1500m" `
    -LimitsMemory "4Gi"
```

#### Azure AKS Deployment
```powershell
.\Provision\DeployAll.ps1 `
    -Namespace production `
    -AppName nodejs-app `
    -Subscription "your-subscription-id" `
    -AksName "your-aks-cluster" `
    -ResourceGroup "your-rg" `
    -DeploymentType "azure" `
    -ImageName "yourregistry.azurecr.io/nodejs-app" `
    -ImageTag "latest"
```

### Deployment Verification

```powershell
# Check pod status
kubectl get pods -l app=nodejs-app -n dev -w

# Check resource utilization
kubectl top pods -n dev

# Check HPA status
kubectl describe hpa nodejs-app-up-cpu -n dev

# Check ingress configuration
kubectl describe ingress nodejs-app -n dev

# View application logs
kubectl logs -l app=nodejs-app -n dev --tail=100 -f
```

---

## Monitoring and Scaling

### Horizontal Pod Autoscaling (HPA)

The deployment includes three HPA configurations for comprehensive scaling:

#### CPU-based Scale Up
```yaml
# Triggered when CPU usage > 60%
scaleTargetRef:
  kind: Deployment
  name: nodejs-app
metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
```

#### Memory-based Scale Up
```yaml
# Triggered when Memory usage > 55%
metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 55
```

#### Scale Down Policy
```yaml
# Triggered when CPU < 35% AND Memory < 30%
behavior:
  scaleDown:
    stabilizationWindowSeconds: 1200  # 20-minute window
    policies:
    - type: Pods
      value: 1
      periodSeconds: 1200
```

### Monitoring Commands

```powershell
# Real-time pod monitoring
kubectl get pods -l app=nodejs-app -n dev -w

# Resource utilization
kubectl top pods -l app=nodejs-app -n dev
kubectl top nodes

# HPA status
kubectl get hpa -n dev -w

# Scaling events
kubectl describe hpa nodejs-app-up-cpu -n dev
kubectl get events --sort-by=.metadata.creationTimestamp -n dev

# Application metrics
kubectl logs -l app=nodejs-app -n dev --tail=50

# Service mesh monitoring (if using Istio)
kubectl get destinationrules,virtualservices -n dev
```

### Performance Tuning

#### Optimize Resource Requests/Limits
```powershell
# Monitor actual usage
kubectl top pods -l app=nodejs-app -n dev --containers

# Adjust based on observations
# Requests should match typical usage
# Limits should handle peak usage with buffer
```

#### Fine-tune HPA Thresholds
```powershell
# Conservative scaling (avoid thrashing)
ScaleUpCpuPercentage = 80
ScaleDownCpuPercentage = 20
ScaleUpStabilizationMinutes = 15
ScaleDownStabilizationMinutes = 30

# Aggressive scaling (rapid response)
ScaleUpCpuPercentage = 50
ScaleDownCpuPercentage = 40
ScaleUpStabilizationMinutes = 3
ScaleDownStabilizationMinutes = 10
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Pods Not Starting
```powershell
# Check pod status
kubectl describe pod <pod-name> -n dev

# Common causes:
# - Image pull errors
# - Resource constraints
# - Configuration errors

# Troubleshoot:
kubectl get events -n dev --sort-by='.lastTimestamp'
kubectl logs <pod-name> -n dev
```

#### 2. Service Not Accessible
```powershell
# Check service configuration
kubectl get svc -n dev
kubectl describe svc nodejs-app -n dev
```

#### 3. Ingress Issues
```powershell
# Check ingress controller
kubectl get pods -n ingress-nginx

# Verify ingress configuration
kubectl describe ingress nodejs-app -n dev

# Check ingress logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller

# For Minikube, ensure ingress addon is enabled
minikube addons enable ingress
```

#### 4. HPA Not Scaling
```powershell
# Check metrics server
kubectl get pods -n kube-system | grep metrics-server

# Verify resource requests are set (required for HPA)
kubectl describe deployment nodejs-app -n dev

# Check HPA status
kubectl describe hpa -n dev

# Enable metrics server in Minikube
minikube addons enable metrics-server
```

#### 5. Image Pull Errors
```powershell
# For Minikube local images
minikube image ls | grep nodejs-app
minikube image load 01-node-app1:latest
```

### Debugging Commands

```powershell
# Pod debugging
kubectl exec -it <pod-name> -n dev -- /bin/bash
kubectl logs <pod-name> -n dev --previous

# Resource debugging
kubectl describe node <node-name>
kubectl top nodes
kubectl top pods -A --sort-by=memory

kubectl get secret -n dev
kubectl describe deployment nodejs-app -n dev

# Event debugging
kubectl get events -n dev --sort-by='.lastTimestamp'
```

---

## Advanced Configuration

### Custom Environment Variables

Add custom environment variables to your deployment:

```yaml
# In patch-deploy.yaml
env:
- name: APP_NAME
  value: APP_NAME_VAR
- name: NODE_ENV
  value: "production"
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: app-secrets
      key: database-url
- name: API_KEY
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: api-key
```

### Health Checks

Enable liveness and readiness probes:

```yaml
# In deploy.yaml (uncomment and modify)
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

### Security Context


```yaml
securityContext:
  runAsUser: 1000          # Non-root user
  runAsNonRoot: true       # Prevent root execution
  readOnlyRootFilesystem: true  # Immutable filesystem
  capabilities:
    drop:
    - ALL                  # Drop all capabilities
  allowPrivilegeEscalation: false
```

### Persistent Storage

For applications requiring persistent storage:

```yaml
# Add volume mounts to deployment
volumeMounts:
- name: app-storage
  mountPath: /app/data

volumes:
- name: app-storage
  persistentVolumeClaim:
    claimName: nodejs-app-pvc
```

### Multi-Environment Configuration

Create environment-specific overlays:

```
environments/
├── dev/
│   ├── kustomization.yaml
│   └── patches/
├── staging/
│   ├── kustomization.yaml
│   └── patches/
└── production/
    ├── kustomization.yaml
    └── patches/
```

---

## Azure Integration

### Azure Application Gateway Ingress Controller (AGIC)

For production Azure deployments, consider using AGIC instead of NGINX:

#### Benefits of AGIC
- **Layer 7 Load Balancing**: Advanced HTTP/HTTPS routing
- **SSL Termination**: Managed SSL certificates
- **Web Application Firewall**: Built-in security protection
- **Auto-scaling**: Integrated with Azure's scaling capabilities
- **Azure Integration**: Seamless integration with Azure services

#### AGIC vs NGINX Comparison

| Feature | NGINX Ingress | AGIC |
|---------|--------------|------|
| **Cost** | Free (compute only) | Azure Application Gateway pricing |
| **SSL Management** | Manual/cert-manager | Azure Key Vault integration |
| **WAF** | Additional setup required | Built-in WAF |
| **Scaling** | Manual/HPA | Automatic with Azure |
| **Monitoring** | Prometheus/Grafana | Azure Monitor integration |
| **Best for** | Development, small-medium loads | Production, enterprise workloads |

#### AGIC Deployment

```yaml
# Example AGIC Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nodejs-app-agic
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
    appgw.ingress.kubernetes.io/request-timeout: "30"
    appgw.ingress.kubernetes.io/connection-draining: "true"
spec:
  tls:
  - hosts:
    - app.yourdomain.com
    secretName: app-tls-secret
  rules:
  - host: app.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nodejs-app
            port:
              number: 80
```

### Azure Container Registry (ACR) Integration

```powershell
# Login to ACR
az acr login --name yourregistry

# Tag and push image
docker tag 01-node-app1:latest yourregistry.azurecr.io/nodejs-app:latest
docker push yourregistry.azurecr.io/nodejs-app:latest

# Update deployment to use ACR
.\Provision\DeployAll.ps1 `
    -ImageName "yourregistry.azurecr.io/nodejs-app" `
    -ImageTag "latest" `
    -DeploymentType "azure"
```

### Azure Key Vault Integration

For secure secret management:

```yaml
# Using Azure Key Vault CSI driver
apiVersion: v1
kind: SecretProviderClass
metadata:
  name: app-secrets
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityClientID: "client-id"
    keyvaultName: "your-keyvault"
    objects: |
      array:
        - |
          objectName: database-connection-string
          objectType: secret
        - |
          objectName: api-key
          objectType: secret
```

---

## Best Practices

### Security
1. **Use non-root containers** with explicit user ID
2. **Enable read-only root filesystem** when possible
3. **Drop unnecessary capabilities** and prevent privilege escalation
4. **Use network policies** to restrict pod-to-pod communication
5. **Scan images for vulnerabilities** before deployment
6. **Store secrets in Kubernetes Secrets** or Azure Key Vault

### Performance
1. **Set appropriate resource requests/limits** based on actual usage
2. **Configure HPA thresholds** to match application behavior
3. **Use readiness probes** to ensure traffic only goes to ready pods

### Reliability
1. **Use multiple replicas** for high availability
2. **Implement circuit breakers** in application code
3. **Set up monitoring and alerting** for key metrics
4. **Regular backup and disaster recovery** strategy

### Operations
1. **Use consistent labeling** across all resources
2. **Implement proper logging** with structured formats
3. **Version control all configurations** 
4. **Document all custom configurations** 
5. **Regular security updates** for base images and dependencies

### Cost Optimization
1. **Right-size resource allocations** based on actual usage
2. **Use cluster autoscaler** for node-level scaling
3. **Monitor resource utilization** and adjust over time
4. **Use spot instances** for non-critical workloads

---
