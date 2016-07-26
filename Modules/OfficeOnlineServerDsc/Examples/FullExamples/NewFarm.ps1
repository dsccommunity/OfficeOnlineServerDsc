<#
.EXAMPLE
    This example shows how to install the prerequisites, binaries and set up a new
    farm on the local server.
#>

    Configuration Example 
    {
        param()

        Import-DscResource -ModuleName OfficeOnlineServerDsc

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
            "InkandHandwritingServices",
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

        OfficeOnlineServerInstall InstallBinaries
        {
            Path      = "C:\Installer\setup.exe"
            DependsOn = $prereqDependencies
        }

        OfficeOnlineServerWebAppsFarm LocalFarm
        {
            InternalURL    = "https://officeonline.contoso.com"
            EditingEnabled = $true
            DependsOn      = "[OfficeOnlineServerInstall]InstallBinaries" 
        }
    }
