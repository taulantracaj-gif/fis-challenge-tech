###############################################################################
<#
.SYNOPSIS
    PatchKustomizationYaml

.DESCRIPTION
    Patches the given kustomization.yaml with new image name and tag values.

.PARAMETER KustomizationYamlFilePath
    Path to the kustomization YAML file.

.PARAMETER ImageName
    New image name to set.

.PARAMETER ImageTag
    New image tag to set.

.EXAMPLE
    .\PatchKustomizationYaml.ps1 -KustomizationYamlFilePath '..\Deployment\kustomization.yaml' ` -ImageName '01-node-app1 -ImageTag 'latest'
#>
param (
    [Parameter(Mandatory = $true)]
    [string] $KustomizationYamlFilePath,

    [Parameter(Mandatory = $true)]
    [string] $ImageName,

    [Parameter(Mandatory = $true)]
    [string] $ImageTag
)

if (Test-Path -Path $KustomizationYamlFilePath) {
    $yamlContent = Get-Content -Path $KustomizationYamlFilePath -Raw

    # Replace placeholders
    $yamlContent = $yamlContent -Replace 'IMAGE_VAR', $ImageName
    $yamlContent = $yamlContent -Replace 'IMAGE_TAG_VAR', $ImageTag

    Write-Output $yamlContent
    Set-Content -Path $KustomizationYamlFilePath -Value $yamlContent -NoNewLine
} else {
    throw ("YAML file '$KustomizationYamlFilePath' could not be found")
}
