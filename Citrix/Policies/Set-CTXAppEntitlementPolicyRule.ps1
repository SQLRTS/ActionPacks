﻿#Requires -Version 5.0

<#
    .SYNOPSIS
        Updates an existing application rule in the site's entitlement policy
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Policies
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter RuleName
        [sr-en] Name of the new rule
        [sr-de] Name der neuen Regel

    .Parameter Description	
        [sr-en] Description of the new rule
        [sr-de] Regel Beschreibung

    .Parameter Enabled
        [sr-en] New rule is initially enabled
        [sr-de] Aktivieren der Regel

    .Parameter ExcludedUserFilterEnabled
        [sr-en] Excluded users filter is initially enabled
        [sr-de] Filter für ausgeschlossene Benutzer aktiveren

    .Parameter ExcludedUsers
        [sr-en] Users and groups who are explicitly denied access to the new rule's desktop group      
        [sr-de] Ausgeschlossene Benutzer
        
    .Parameter IncludedUserFilterEnabled
        [sr-en] Included users filter is initially enabled
        [sr-de] Filter für Benutzer aktiveren
        
    .Parameter IncludedUsers
        [sr-en] Users and groups who are granted access to the new rule's desktop group        
        [sr-de] Benutzer

    .Parameter SessionReconnection
        [sr-en] Defines reconnection (roaming) behavior for sessions launched using this rule
        [sr-de] Definiert das Wiederverbindungsverhalten (Roaming) für Sitzungen, die mit dieser Regel gestartet wurden

    .Parameter LeasingBehavior
        [sr-en] Desired connection leasing behavior applied to sessions launched using this entitlement
        [sr-de] Verhalten beim Verbindungsleasing für Sitzungen, die mit dieser Berechtigung gestartet werden
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$RuleName,
    [string]$SiteServer,
    [string]$Description,
    [bool]$Enabled,
    [bool]$ExcludedUserFilterEnabled,
    [string[]]$ExcludedUsers,
    [bool]$IncludedUserFilterEnabled,
    [string[]]$IncludedUsers,
    [ValidateSet('Allowed','Disallowed')]
    [string]$LeasingBehavior,
    [ValidateSet('Always','DisconnectedOnly','SameEndpointOnly')]
    [string]$SessionReconnection
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','Description','DesktopGroupUid','Enabled','ExcludedUsers','IncludedUsers')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Change App Entitlement rule $($RuleName)" -LoggingID ([ref]$LogID)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Name' = $RuleName
                            'Enabled' = $Enabled
                            'LoggingID' =$LogID
                            'PassThru' = $null
                            }    
    
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('ExcludedUserFilterEnabled') -eq $true){
        $cmdArgs.Add('ExcludedUserFilterEnabled',$ExcludedUserFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('ExcludedUsers') -eq $true){
        $cmdArgs.Add('ExcludedUsers',$ExcludedUsers)
    }
    if($PSBoundParameters.ContainsKey('IncludedUserFilterEnabled') -eq $true){
        $cmdArgs.Add('IncludedUserFilterEnabled',$IncludedUserFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('IncludedUsers') -eq $true){
        $cmdArgs.Add('IncludedUsers',$IncludedUsers)
    }
    if($PSBoundParameters.ContainsKey('LeasingBehavior') -eq $true){
        $cmdArgs.Add('LeasingBehavior',$LeasingBehavior)
    }
    if($PSBoundParameters.ContainsKey('SessionReconnection') -eq $true){
        $cmdArgs.Add('SessionReconnection',$SessionReconnection)
    }

    $ret = Set-BrokerAppEntitlementPolicyRule @cmdArgs | Select-Object $Properties
    $success = $true
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}