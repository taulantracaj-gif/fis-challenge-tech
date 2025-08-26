###############################################################################
<#
.SYNOPSIS
    PatchDeploymentYaml

.DESCRIPTION
    Patches the given Deployment YAML with resource requests/limits, environment variables, and replicas.

.PARAMETER DeploymentYamlFilePath
    Path to the deployment YAML file.

.PARAMETER RequestsCpu
    CPU requests value (e.g. 100m).

.PARAMETER RequestsMemory
    Memory requests value (e.g. 256Mi).

.PARAMETER LimitsCpu
    CPU limits value (e.g. 500m).

.PARAMETER LimitsMemory
    Memory limits value (e.g. 1Gi).

.PARAMETER AppName
    Value for environment variable APP_NAME.

.PARAMETER Replicas
    Replica count for the second deployment block.

.EXAMPLE
    .\PatchDeploymentYaml.ps1 -DeploymentYamlFilePath '..\Deployment\' `
        -RequestsCpu '100m' -RequestsMemory '256Mi' `
        -LimitsCpu '500m' -LimitsMemory '1Gi' `
        -AppName 'nodejs-app' -Replicas 3
            .\PatchDeploymentYaml.ps1 -DeploymentYamlFilePath '..\Deployment\patch-deploy.yaml'  -RequestsCpu '100m' -RequestsMemory '256Mi'  -LimitsCpu '500m' -LimitsMemory '1Gi'  -AppName 'nodejs-app' -Replicas 3
#>
param (
    [Parameter(Mandatory = $True)]
    [string] $DeploymentYamlFilePath,

    [Parameter(Mandatory = $True)]
    [string] $RequestsCpu,

    [Parameter(Mandatory = $True)]
    [string] $RequestsMemory,

    [Parameter(Mandatory = $True)]
    [string] $LimitsCpu,

    [Parameter(Mandatory = $True)]
    [string] $LimitsMemory,

    [Parameter(Mandatory = $True)]
    [string] $AppName,

    [Parameter(Mandatory = $True)]
    [int] $Replicas
)

if (Test-Path -Path $DeploymentYamlFilePath) {
    $yamlContent = Get-Content -Path $DeploymentYamlFilePath -Raw

    # Replace placeholders
    $yamlContent = $yamlContent -Replace 'RequestsCpu_VAR', $RequestsCpu
    $yamlContent = $yamlContent -Replace 'RequestsMemory_VAR', $RequestsMemory
    $yamlContent = $yamlContent -Replace 'LimitCpu_VAR', $LimitsCpu
    $yamlContent = $yamlContent -Replace 'LimitMemory_VAR', $LimitsMemory
    $yamlContent = $yamlContent -Replace 'APP_NAME_VAR', $AppName
    $yamlContent = $yamlContent -Replace 'Replicas_VAR', $Replicas

    Write-Output $yamlContent
    Set-Content -Path $DeploymentYamlFilePath -Value $yamlContent -NoNewLine
} else {
    throw ("YAML file '$DeploymentYamlFilePath' could not be found")
}
