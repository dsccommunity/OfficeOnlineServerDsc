<#
.EXAMPLE
    This example shows how to install the binaries for office online server to the local server.
#>

    Configuration Example 
    {
        param()

        Import-DscResource -ModuleName OfficeOnlineServerDsc

        OfficeOnlineServerInstall InstallBinaries
        {
            Path = "C:\Installer\setup.exe"
        }
    }
