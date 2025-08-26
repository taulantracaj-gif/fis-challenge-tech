<#
.SYNOPSIS
    Patch multiple HorizontalPodAutoscaler YAML patch files with given parameters.

.DESCRIPTION
    Patches the specified patch YAML files for CPU scale-up, memory scale-up, and scale-down HorizontalPodAutoscalers
    by replacing placeholders with parameter values.

.PARAMETER CpuPatchFilePath
    Path to the CPU scale-up HPA patch YAML.

.PARAMETER MemoryPatchFilePath
    Path to the Memory scale-up HPA patch YAML.

.PARAMETER DownPatchFilePath
    Path to the scale-down HPA patch YAML.

.PARAMETER MinReplicas
    Minimum number of replicas.

.PARAMETER MaxReplicas
    Maximum number of replicas.

.PARAMETER ScaleUpCpuPercentage
    Target CPU utilization percentage for scale-up.

.PARAMETER ScaleUpMemoryPercentage
    Target Memory utilization percentage for scale-up.

.PARAMETER ScaleDownCpuPercentage
    Target CPU utilization percentage for scale-down.

.PARAMETER ScaleDownMemoryPercentage
    Target Memory utilization percentage for scale-down.

.PARAMETER ScaleUpStabilizationMinutes
    Stabilization window in minutes for scale-up.

.PARAMETER ScaleDownStabilizationMinutes
    Stabilization window in minutes for scale-down.

.EXAMPLE
    .\PatchHpaYaml.ps1 -CpuPatchFilePath './patch-nodejs-app-up-cpu.yaml' `
                       -MemoryPatchFilePath './patch-nodejs-app-up-memory.yaml' `
                       -DownPatchFilePath './patch-nodejs-app-down.yaml' `
                       -MinReplicas 2 -MaxReplicas 4 `
                       -ScaleUpCpuPercentage 70 -ScaleUpMemoryPercentage 70 `
                       -ScaleDownCpuPercentage 30 -ScaleDownMemoryPercentage 30 `
                       -ScaleUpStabilizationMinutes 10 -ScaleDownStabilizationMinutes 20
    .\PatchHpaYaml.ps1 -CpuPatchFilePath '..\HPA\patch-nodejs-app-up-cpu.yaml' -MemoryPatchFilePath '..\HPA\patch-nodejs-app-up-memory.yaml' -DownPatchFilePath '..\HPA\patch-nodejs-app-down.yaml' -MinReplicas 2 -MaxReplicas 4 -ScaleUpCpuPercentage 70 -ScaleUpMemoryPercentage 70 -ScaleDownCpuPercentage 30 -ScaleDownMemoryPercentage 30 -ScaleUpStabilizationMinutes 10 -ScaleDownStabilizationMinutes 20

#>

param (
    [Parameter(Mandatory = $true)]
    [string] $CpuPatchFilePath,

    [Parameter(Mandatory = $true)]
    [string] $MemoryPatchFilePath,

    [Parameter(Mandatory = $true)]
    [string] $DownPatchFilePath,

    [Parameter(Mandatory = $true)]
    [int] $MinReplicas,

    [Parameter(Mandatory = $true)]
    [int] $MaxReplicas,

    [Parameter(Mandatory = $true)]
    [int] $ScaleUpCpuPercentage,

    [Parameter(Mandatory = $true)]
    [int] $ScaleUpMemoryPercentage,

    [Parameter(Mandatory = $true)]
    [int] $ScaleDownCpuPercentage,

    [Parameter(Mandatory = $true)]
    [int] $ScaleDownMemoryPercentage,

    [Parameter(Mandatory = $true)]
    [int] $ScaleUpStabilizationMinutes,

    [Parameter(Mandatory = $true)]
    [int] $ScaleDownStabilizationMinutes
)

function Patch-HpaFile {
    param(
        [string] $FilePath,
        [hashtable] $Replacements
    )

    if (-not (Test-Path -Path $FilePath)) {
        throw "YAML file '$FilePath' could not be found"
    }

    $content = Get-Content -Path $FilePath -Raw

    foreach ($key in $Replacements.Keys) {
        $value = $Replacements[$key]
        $content = $content -Replace [regex]::Escape($key), [string]$value
    }

    Set-Content -Path $FilePath -Value $content -NoNewLine
    Write-Output "Patched file '$FilePath'"
}

# Patch CPU scale-up HPA
Patch-HpaFile -FilePath $CpuPatchFilePath -Replacements @{
    'MinReplicas_VAR' = $MinReplicas
    'MaxReplicas_VAR' = $MaxReplicas
    'ScaleUpCpuUtilization_VAR' = $ScaleUpCpuPercentage
    'ScaleUpStabilizationMinutes_VAR' = ($ScaleUpStabilizationMinutes * 60)
}

# Patch Memory scale-up HPA
Patch-HpaFile -FilePath $MemoryPatchFilePath -Replacements @{
    'MinReplicas_VAR' = $MinReplicas
    'MaxReplicas_VAR' = $MaxReplicas
    'ScaleUpMemoryUtilization_VAR' = $ScaleUpMemoryPercentage
    'ScaleUpStabilizationMinutes_VAR' = ($ScaleUpStabilizationMinutes * 60)
}

# Patch scale-down HPA
Patch-HpaFile -FilePath $DownPatchFilePath -Replacements @{
    'MinReplicas_VAR' = $MinReplicas
    'MaxReplicas_VAR' = $MaxReplicas
    'ScaleDownCpuUtilization_VAR' = $ScaleDownCpuPercentage
    'ScaleDownMemoryUtilization_VAR' = $ScaleDownMemoryPercentage
    'ScaleDownStabilizationMinutes_VAR' = ($ScaleDownStabilizationMinutes * 60)
}

Write-Output "All HPA patch files updated successfully."
