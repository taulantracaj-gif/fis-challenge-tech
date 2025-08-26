###############################################################################
<#
.SYNOPSIS
    PatchDeploymentReplicasYaml

.DESCRIPTION
    Patches the given Deployment YAML with the specified replica count.

.PARAMETER DeploymentYamlFilePath
    Path to the deployment YAML file.

.PARAMETER Replicas
    Replica count to set in the YAML.

.EXAMPLE
    .\PatchDeploymentReplicasYaml.ps1 -DeploymentYamlFilePath '..\Deployment\patch-deploy.yaml' -Replicas 3
#>
param (
    [Parameter(Mandatory = $True)]
    [string] $DeploymentYamlFilePath,

    [Parameter(Mandatory = $True)]
    [int] $Replicas
)

if (Test-Path -Path $DeploymentYamlFilePath) {
    $yamlContent = Get-Content -Path $DeploymentYamlFilePath -Raw

    # Replace the replicas placeholder
    $yamlContent = $yamlContent -Replace 'Replicas_VAR', $Replicas

    Write-Output $yamlContent
    Set-Content -Path $DeploymentYamlFilePath -Value $yamlContent -NoNewLine
} else {
    throw ("YAML file '$DeploymentYamlFilePath' could not be found")
}
