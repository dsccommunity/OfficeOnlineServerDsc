
<#PSScriptInfo

.VERSION 1.5.0

.GUID 80d306fa-8bd4-4a8d-9f7a-bf40df95e661

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS

.LICENSEURI https://github.com/dsccommunity/OfficeOnlineServerDsc/blob/master/LICENSE

.PROJECTURI https://github.com/dsccommunity/OfficeOnlineServerDsc

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Updated author, copyright notice, and URLs.

.PRIVATEDATA

#>

<#
.DESCRIPTION
 This example shows how to install cumulative updates for office online server to the local server.
#>

Configuration Example
{
    Param()

    Import-DscResource -ModuleName OfficeOnlineServerDsc

    OfficeOnlineServerProductUpdate InstallCU
    {
        Ensure    = "Present"
        SetupFile = "C:\Installer\wacserver2019-kb4484223-fullfile-x64-glb.exe"
        Servers   = @("OOS1", "OOS2")
    }
}
