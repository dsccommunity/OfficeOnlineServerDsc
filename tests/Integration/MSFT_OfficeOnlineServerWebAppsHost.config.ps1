$webAppsHost = @{
    Domains = 'example.contoso.com'
}

configuration MSFT_OfficeOnlineServerFarm_config {

    Import-DscResource -ModuleName OfficeOnlineServerDsc

    node localhost {

        OfficeOnlineServerFarm Integration_Test
        {
            InternalURL        = $webAppsFarm.InternalURL
            ExternalURL        = $webAppsFarm.ExternalURL
            AllowHttp          = $webAppsFarm.AllowHttp
            EditingEnabled     = $webAppsFarm.EditingEnabled
            SSLOffloaded       = $webAppsFarm.SSLOffloaded
            LogLocation        = $webAppsFarm.LogLocation
            LogRetentionInDays = $webAppsFarm.LogRetentionInDays
            LogVerbosity       = $webAppsFarm.LogVerbosity
            Proxy              = $webAppsFarm.Proxy
            AllowCEIP          = $webAppsFarm.AllowCEIP
        }

        OfficeOnlineServerHost Integration_Test
        {
            IsSingleInstance = 'Yes'
            Domains          = $webAppsHost.Domains
        }
    }
}

