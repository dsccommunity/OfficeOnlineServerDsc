
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
 This example shows how to install the prerequisites, binaries and set up a new
 farm on the local Windows Server 2016 machine.
#>

Configuration Example
{
    Param()

    Import-DscResource -ModuleName OfficeOnlineServerDsc

    # For Windows Server 2012 R2, ass the 'InkandHandwritingServices' feature as well.
    $requiredFeatures = @(
        "Web-Server",
        "Web-Mgmt-Tools",
        "Web-Mgmt-Console",
        "Web-WebServer",
        "Web-Common-Http",
        "Web-Default-Doc",
        "Web-Static-Content",
        "Web-Performance",
        "Web-Stat-Compression",
        "Web-Dyn-Compression",
        "Web-Security",
        "Web-Filtering",
        "Web-Windows-Auth",
        "Web-App-Dev",
        "Web-Net-Ext45",
        "Web-Asp-Net45",
        "Web-ISAPI-Ext",
        "Web-ISAPI-Filter",
        "Web-Includes",
        "NET-Framework-Features",
        "NET-Framework-Core",
        "NET-HTTP-Activation",
        "NET-Non-HTTP-Activ",
        "NET-WCF-HTTP-Activation45",
        "Windows-Identity-Foundation"
    )

    foreach ($feature in $requiredFeatures)
    {
        WindowsFeature "WindowsFeature-$feature"
        {
            Ensure = 'Present'
            Name   = $feature
        }
    }

    $prereqDependencies = $RequiredFeatures | ForEach-Object -Process {
        return "[WindowsFeature]WindowsFeature-$_"
    }

    OfficeOnlineServerInstall 'InstallBinaries'
    {
        Ensure    = "Present"
        Path      = "C:\Installer\setup.exe"
        DependsOn = $prereqDependencies
    }

    OfficeOnlineServerFarm 'LocalFarm'
    {
        InternalURL    = "https://officeonline.contoso.com"
        EditingEnabled = $true
        DependsOn      = "[OfficeOnlineServerInstall]InstallBinaries"
    }

    OfficeOnlineServerHost 'HostsAllowList'
    {
        IsSingleInstance = 'Yes'
        AllowList        = 'example.contoso.com'
        DependsOn        = "[OfficeOnlineServerFarm]LocalFarm"
    }
}
