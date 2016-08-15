$webAppsFarm = @{
    InternalURL = 'http://webfarm.contoso.com/'
    ExternalURL = 'http://externalfarm.contoso.com/'
    AllowHttp = $true
    EditingEnabled = $true
    SSLOffloaded = $false
    LogLocation = 'C:\Logs'
    LogRetentionInDays = 7
    LogVerbosity = 'Verbose'
    Proxy = 'http://proxy.contoso.com/'
    AllowCEIP = $true    
}

configuration MSFT_OfficeOnlineServerWebAppsFarm_config {
    
    Import-DscResource -ModuleName OfficeOnlineServerDsc
    node localhost {
        
        OfficeOnlineServerWebAppsFarm Integration_Test
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
    }
}

