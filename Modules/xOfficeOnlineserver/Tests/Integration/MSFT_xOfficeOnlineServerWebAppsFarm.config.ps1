<#
.Synopsis
   DSC Configuration Template for DSC Resource Integration tests.
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Integration\ folder and rename <ResourceName>.config.ps1 (e.g. MSFT_xFirewall.config.ps1)
     2. Customize TODO sections.

.NOTES
#>

$webAppsFarm = @{
    InternalURL = 'http://webfarm.contoso.com/'
    ExternalURL = 'http://externalfarm.contoso.com/'
    AllowHttp = $true
    EditingEnabled = $true
    SSLOffloaded = $false
    #CertificateName = 'Farm Cert' - do not have a way to create this before test
    LogLocation = 'C:\Logs'
    LogRetentionInDays = 7
    LogVerbosity = 'Verbose'
    Proxy = 'http://proxy.contoso.com/'
    AllowCEIP = $true    
}

configuration MSFT_xOfficeOnlineServerWebAppsFarm_config {
    
    Import-DscResource -ModuleName xOfficeOnlineServer
    node localhost {
        
        xOfficeOnlineServerWebAppsFarm Integration_Test
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

# TODO: (Optional): Add More Configuration Templates
