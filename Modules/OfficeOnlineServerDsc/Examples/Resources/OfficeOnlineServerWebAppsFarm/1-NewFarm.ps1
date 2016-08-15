<#
.EXAMPLE
    This example shows how to create a basic web apps farm. There are many more options
    that can be configured on this resource, but this minimum configuration will deploy
    a farm that has editing enabled.
#>

    Configuration Example 
    {
        param()

        Import-DscResource -ModuleName OfficeOnlineServerDsc

        OfficeOnlineServerWebAppsFarm LocalFarm
        {
            InternalURL    = "https://officeonline.contoso.com"
            EditingEnabled = $true
        }
    }
