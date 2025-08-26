<#
.SYNOPSIS
    Full Kubernetes deployment for any NodeJS app (or other apps)

.DESCRIPTION
    Runs all patch scripts and deploys Deployment, Service, HPA, and Ingress.
    Uses AppName parameter to customize app-specific labels and environment variables.
    Waits for pods with the given app label to be ready before continuing.
#>

param (
    [Parameter(Mandatory = $false)]
    [string] $Namespace = "dev",

    [Parameter(Mandatory = $false)]
    [string] $AppName = "nodejs-app",

    # HPA parameters
    [Parameter(Mandatory = $false)]
    [int] $MinReplicas = 2,
    [Parameter(Mandatory = $false)]
    [int] $MaxReplicas = 4,
    [Parameter(Mandatory = $false)]
    [int] $ScaleUpCpuPercentage = 60,
    [Parameter(Mandatory = $false)]
    [int] $ScaleUpMemoryPercentage = 55,
    [Parameter(Mandatory = $false)]
    [int] $ScaleDownCpuPercentage = 35,
    [Parameter(Mandatory = $false)]
    [int] $ScaleDownMemoryPercentage = 30,
    [Parameter(Mandatory = $false)]
    [int] $ScaleUpStabilizationMinutes = 10,
    [Parameter(Mandatory = $false)]
    [int] $ScaleDownStabilizationMinutes = 20,

    # Deployment parameters
    [Parameter(Mandatory = $false)]
    [string] $ImageName = "01-node-app1",
    [Parameter(Mandatory = $false)]
    [string] $ImageTag = "latest",
    [Parameter(Mandatory = $false)]
    [string] $RequestsCpu = "100m",
    [Parameter(Mandatory = $false)]
    [string] $RequestsMemory = "256Mi",
    [Parameter(Mandatory = $false)]
    [string] $LimitsCpu = "500m",
    [Parameter(Mandatory = $false)]
    [string] $LimitsMemory = "1Gi",

    # Kubernetes deployment parameters
    [Parameter(Mandatory = $false)]
    [string] $Subscription = "minikube",
    [Parameter(Mandatory = $false)]
    [string] $AksName = "minikube",
    [Parameter(Mandatory = $false)]
    [string] $ResourceGroup = "minikube",
    [Parameter(Mandatory = $false)]
    [string] $Filename = "",
    [Parameter(Mandatory = $false)]
    [string] $DeploymentMode = "kustomize",
    [Parameter(Mandatory = $false)]
    [string] $DeploymentType = "minikube"
)

# Set script paths
$ScriptDir = Join-Path $PSScriptRoot "..\scripts"
$DeploymentDir = Join-Path $PSScriptRoot "..\Deployment"
$ServiceDir    = Join-Path $PSScriptRoot "..\Service"
$HpaDir        = Join-Path $PSScriptRoot "..\HPA"
$IngressDir    = Join-Path $PSScriptRoot "..\Ingress"

function Wait-ForPodsReady {
    param (
        [string]$AppName,
        [string]$Namespace,
        [int]$TimeoutSeconds = 300
    )
    $LabelSelector = "app=$AppName"
    Write-Host "Waiting for pods with label '$LabelSelector' in namespace '$Namespace' to be ready..."
    try {
        kubectl wait --for=condition=Ready pod -l $LabelSelector -n $Namespace --timeout=${TimeoutSeconds}s | Out-Null
        Write-Host "Pods are ready."
    }
    catch {
        Write-Warning "Timeout waiting for pods to become ready."
    }
}

Write-Host "=== 1. Patch HPA YAMLs ==="
& "$ScriptDir\PatchHpaYaml.ps1" `
    -CpuPatchFilePath "$HpaDir\patch-nodejs-app-up-cpu.yaml" `
    -MemoryPatchFilePath "$HpaDir\patch-nodejs-app-up-memory.yaml" `
    -DownPatchFilePath "$HpaDir\patch-nodejs-app-down.yaml" `
    -MinReplicas $MinReplicas `
    -MaxReplicas $MaxReplicas `
    -ScaleUpCpuPercentage $ScaleUpCpuPercentage `
    -ScaleUpMemoryPercentage $ScaleUpMemoryPercentage `
    -ScaleDownCpuPercentage $ScaleDownCpuPercentage `
    -ScaleDownMemoryPercentage $ScaleDownMemoryPercentage `
    -ScaleUpStabilizationMinutes $ScaleUpStabilizationMinutes `
    -ScaleDownStabilizationMinutes $ScaleDownStabilizationMinutes

Write-Host "=== 2. Patch Kustomization YAML ==="
& "$ScriptDir\PatchDeploymentKustomizationYaml.ps1" `
    -KustomizationYamlFilePath "$DeploymentDir\kustomization.yaml" `
    -ImageName $ImageName `
    -ImageTag $ImageTag

Write-Host "=== 3. Patch Deployment YAML ==="
& "$ScriptDir\PatchDeploymentYaml.ps1" `
    -DeploymentYamlFilePath "$DeploymentDir\patch-deploy.yaml" `
    -RequestsCpu $RequestsCpu `
    -RequestsMemory $RequestsMemory `
    -LimitsCpu $LimitsCpu `
    -LimitsMemory $LimitsMemory `
    -AppName $AppName `
    -Replicas $MinReplicas

Write-Host "=== 4. Patch Deployment Replicas YAML ==="
& "$ScriptDir\PatchDeploymentReplicasYaml.ps1" `
    -DeploymentYamlFilePath "$DeploymentDir\patch-deploy-replicas.yaml" `
    -Replicas $MinReplicas


function Deploy-Folder {
    param (
        [string]$FolderPath
    )
    & "$ScriptDir\DeployToKubernetes.ps1" `
        -Subscription $Subscription `
        -AksName $AksName `
        -AksNamespace $Namespace `
        -ResourceGroup $ResourceGroup `
        -Filepath $FolderPath `
        -Filename $Filename `
        -DeploymentMode $DeploymentMode `
        -DeploymentType $DeploymentType
}

Write-Host "=== 4. Deploy Deployment ==="
Deploy-Folder -FolderPath $DeploymentDir
Wait-ForPodsReady -AppName $AppName -Namespace $Namespace -TimeoutSeconds 300

Write-Host "=== 5. Deploy Service ==="
Deploy-Folder -FolderPath $ServiceDir

Write-Host "=== 6. Deploy HPA ==="
Deploy-Folder -FolderPath $HpaDir
Wait-ForPodsReady -AppName $AppName -Namespace $Namespace -TimeoutSeconds 300

Write-Host "=== 7. Deploy Ingress ==="
Deploy-Folder -FolderPath $IngressDir

Write-Host "=== Deployment complete! Fetching final resource statuses... ==="
kubectl get pods -l "app=$AppName" -n $Namespace -o wide
kubectl get services -n $Namespace
kubectl get hpa -n $Namespace
kubectl get ingress -n $Namespace
