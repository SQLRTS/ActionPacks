﻿#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Removes the specified datacenter

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Datacenter

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter DatacenterID
        [sr-en] ID of the datacenter
        [sr-de] Id des Datacenters
        
    .Parameter DatacenterName
        [sr-en] Name of the datacenter
        [sr-de] Name des Datacenters
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$DatacenterName,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$DatacenterID
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:dCenter = Get-Datacenter -Server $Script:vmServer -Id $DatacenterID -ErrorAction Stop
    }
    else {
        $Script:dCenter = Get-Datacenter -Server $Script:vmServer -Name $DatacenterName -ErrorAction Stop
    }
    Remove-Datacenter -Datacenter $Script:dCenter -Server $Script:vmServer -Confirm:$false -ErrorAction Stop

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Datacenter $($Script:dCenter.Name) removed"
    }
    else{
        Write-Output "Datacenter $($Script:dCenter.Name) removed"
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