configuration MSFT_OosInstall_config {
    Import-DscResource -ModuleName 'OfficeOnlineServerDsc'
    node localhost {
        OosInstall Integration_Test {
            Path = 'C:\InstallBits\setup.exe'
        }
    }
}
