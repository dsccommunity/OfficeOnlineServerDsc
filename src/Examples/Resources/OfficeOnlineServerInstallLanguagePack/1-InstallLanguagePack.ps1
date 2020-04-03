
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
 This example shows how to install a language pack for Office Online
 Server. Make sure to use this resource on every Server in the farm.
 Currently there is no support for uninstalling the language pack.
#>

Configuration Example
{
    Param()

    Import-DscResource -ModuleName OfficeOnlineServerDsc

    OfficeOnlineServerInstallLanguagePack CurrentLanguagePack
    {
        Ensure    = "Present"
        BinaryDir = "D:\"
        Language  = "de-de"
    }
}
