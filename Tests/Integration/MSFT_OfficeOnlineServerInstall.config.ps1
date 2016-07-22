<#
.Synopsis
   DSC Configuration Template for DSC Resource Integration tests.
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Integration\ folder and rename <ResourceName>.config.ps1 (e.g. MSFT_xFirewall.config.ps1)
     2. Customize TODO sections.

.NOTES
#>



configuration MSFT_OfficeOnlineServerInstall_config {
    Import-DscResource -ModuleName 'OfficeOnlineServerDsc'
    node localhost {
        # TODO: Modify ResourceFriendlyName (e.g. xFirewall Integration_Test)
        OfficeOnlineServerInstall Integration_Test {
            Path = 'C:\InstallBits\setup.exe'
        }
    }
}

# TODO: (Optional): Add More Configuration Templates
