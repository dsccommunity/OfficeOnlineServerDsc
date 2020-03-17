<#
.EXAMPLE
    This example shows how to install cumulative updates for office online server to the local server.
#>

    Configuration Example
    {
        param()

        Import-DscResource -ModuleName OfficeOnlineServerDsc

        OfficeOnlineServerProductUpdate InstallCU
        {
            Ensure    = "Present"
            SetupFile = "C:\Installer\wacserver2019-kb4484223-fullfile-x64-glb.exe"
            Servers   = @("OOS1","OOS2")
        }
    }
