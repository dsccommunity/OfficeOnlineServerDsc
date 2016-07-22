configuration WebAppsFarm
{
    Import-DscResource -ModuleName OfficeOnlineServerDsc

    node localhost
    {
        OfficeOnlineServerWebAppsFarm FirstFarm
        {
            InternalURL = 'http://webfarm.contoso.com/'
            AllowHttp = $true
            EditingEnabled = $true
        }
    }
}

WebAppsFarm -OutputPath C:\DSC
Start-DscConfiguration -Path C:\DSC -Wait -Verbose -Force
