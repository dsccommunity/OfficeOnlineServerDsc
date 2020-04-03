
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
 This example shows how to create a basic web apps farm. There are many more options
 that can be configured on this resource, but this minimum configuration will deploy
 a farm that has editing enabled.
#>

Configuration Example
{
    Param()

    Import-DscResource -ModuleName OfficeOnlineServerDsc

    OfficeOnlineServerFarm LocalFarm
    {
        InternalURL    = "https://officeonline.contoso.com"
        EditingEnabled = $true
    }
}
