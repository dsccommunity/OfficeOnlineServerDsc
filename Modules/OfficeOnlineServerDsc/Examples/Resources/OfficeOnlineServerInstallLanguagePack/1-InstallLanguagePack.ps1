<#
.EXAMPLE
    This example shows how to install a language pack for Office Online
    Server. Make sure to use this resource on every Server in the farm.
    Currently there is no support for uninstalling the language pack.
#>

Configuration Example 
{
    param()

    Import-DscResource -ModuleName OfficeOnlineServerDsc

    OfficeOnlineServerInstallLanguagePack CurrentLanguagePack
    {
        Ensure = "Present"
        BinaryDir = "D:\"
        Language = "de-de"
    }
}
