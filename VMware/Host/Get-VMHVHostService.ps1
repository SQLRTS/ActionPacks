#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves information about a host service

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter HostName
    Specifies the host for which you want to retrieve the available services

.Parameter ServiceKey
    Specifies the key of the service you want to retrieve

.Parameter ServiceLabel
    Specifies the label of the service you want to retrieve

.Parameter Refresh
    Indicates whether the cmdlet refreshes the service information before retrieving it
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [string]$ServiceKey,
    [string]$ServiceLabel,
    [switch]$Refresh
)

Import-Module VMware.PowerCLI

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:Output = @()
    $Script:services = Get-VMHostService -Server $Script:vmServer -VMHost $HostName -Refresh:$Refresh -ErrorAction Stop | Select-Object *
    
    if([System.String]::IsNullOrWhiteSpace($ServiceKey) -eq $false){
        $Script:Output += $Script:services  | Where-Object {$_.Key -like $ServiceKey}
    }
    if([System.String]::IsNullOrWhiteSpace($ServiceLabel) -eq $false){
        $Script:Output += $Script:services  | Where-Object { $_.Label -like $ServiceLabel}  
    }
    if($Script:Output.Count -le 0){
        $Script:Output = $Script:services
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}