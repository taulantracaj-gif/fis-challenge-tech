<#
.SYNOPSIS
    Create a resource from a file

.DESCRIPTION
    Create a resource from a file with two options what is executed.
    Option 1: deploy from a specific file
    Option 2: deploy from a location(with kustomization)

.PARAMETER Subscription
    Azure Subscription

.PARAMETER AksName
    Kubernetes Name

.PARAMETER AksNamespace
    Kubernetes Namespace

.PARAMETER ResourceGroup
    Azure Resource Group

.PARAMETER Filepath
    Base path to the resource you want to deploy

.PARAMETER Filename
    Name of the file to be deployed if script is executed with DeploymentMode 'filename'

.PARAMETER DeploymentMode
    - filename
    - kustomize

.NOTES

.EXAMPLE
     .\DeployToKubernetes.ps1 
        -Subscription "Europe" 
        -AksName "Name" 
        -AksNamespace "Namespace" 
        -ResourceGroup "oned-resourcegroup" 
        -Filepath "..\HPA"
        -Filename ""
        -DeploymentMode "kustomize"
        .\DeployToKubernetes.ps1  -Subscription 'test' -AksName 'test' -AksNamespace 'test-namespace' -FilePath '..\HPA\' -Filename '' -DeploymentMode 'kustomize'
.NOTES

#>

param (
    [Parameter(Mandatory=$false, HelpMessage="Specify the context subscription")]
    [ValidateNotNullOrEmpty()]
    [string] $Subscription = "",

    [Parameter(Mandatory=$true, HelpMessage="Specify the name of your Kubernetes cluster")]
    [ValidateNotNullOrEmpty()]
    [string] $AksName,

    [Parameter(Mandatory=$true, HelpMessage="Specify the name of your Kubernetes Namespace - Example: SitecoreNS")]
    [ValidateNotNullOrEmpty()]
    [string] $AksNamespace,

    [Parameter(Mandatory=$true, HelpMessage="Specify the target resource group")]
    [ValidateNotNullOrEmpty()]
    [string] $ResourceGroup,

    [Parameter(Mandatory=$false, HelpMessage="Path to location of your deployment resources")]
    [string] $Filepath,

    [Parameter(Mandatory=$false, HelpMessage="Name of the file to deploy")]
    [string] $Filename,

    [Parameter(Mandatory=$true, 
                HelpMessage="Specify the main parameter of your kubernetes deployment.
                    filename: Deployment of a specific yaml file that requires both Filepath and Filename
                    kustomize: Deployment of a location which will apply kustomization and patches. Requires only filepath")]
    [ValidateNotNullOrEmpty()]
    [string] $DeploymentMode,

    [Parameter(Mandatory=$false, HelpMessage="Deployment Type")]
    [string] $DeploymentType
)

## Validate given input
if ($DeploymentMode -eq "filename")
{
    if([string]::IsNullOrEmpty($Filepath))
    {
        throw "Deployment mode 'filename' requires a filepath"
    }

    if ([string]::IsNullOrEmpty($Filename))
    {
        throw "Deployment mode 'filename' requires a filename"
    }
}
elseif ($DeploymentMode -eq "kustomize") 
{
    if ([string]::IsNullOrEmpty($Filepath))
    {
        throw "Deployment mode 'kustomize' requires a filepath"
    }    
}

## Azure Authentication
if ($DeploymentType -eq "azure")
{
    az account set --subscription $Subscription
    az aks get-credentials -n $AksName -g $ResourceGroup
}

if ($DeploymentMode -eq "filename")
{
    $fullpath = [string]::Format("{0}/{1}", $Filepath, $Filename)
    kubectl apply -f $fullpath  --namespace $AksNamespace
}

if ($DeploymentMode -eq "kustomize")
{
    $fullpath = [string]::Format("{0}/", $Filepath)
    kubectl apply -k $fullpath --namespace $AksNamespace
}

# kubectl get pods -o wide --namespace $AksNamespace