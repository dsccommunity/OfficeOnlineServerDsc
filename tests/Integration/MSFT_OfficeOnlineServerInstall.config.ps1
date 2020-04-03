configuration MSFT_OfficeOnlineServerInstall_config {
    Import-DscResource -ModuleName 'OfficeOnlineServerDsc'
    node localhost {
        OfficeOnlineServerInstall Integration_Test {
            Path = 'C:\InstallBits\setup.exe'
        }
    }
}
