
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
 This example shows how to adds a host domain to the list of host domains
 to which Office Online Server allows file operations requests.
#>

Configuration Example
{
    Param()

    Import-DscResource -ModuleName OfficeOnlineServerDsc

    OfficeOnlineServerHost 'HostsAllowList'
    {
        IsSingleInstance = 'Yes'
        Domains          = 'example.contoso.com'
    }
}
