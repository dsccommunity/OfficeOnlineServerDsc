configuration NewOfficeWebAppsFarm
{

    Node oss1
    {
        #Install required Windows features
        Foreach($feature in $node.RequiredFeatures)
        {
            WindowsFeature $feature
            {
                Ensure = 'Present'
                Name = $feature
            }
        }


        #region to configure LCM
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }
    }

}

$ConfigurationData = @{
    AllNodes = @(

        @{
            NodeName = 'oss1'
            RequiredFeatures = "Web-Server","Web-Mgmt-Tools","Web-Mgmt-Console","Web-WebServer","Web-Common-Http","Web-Default-Doc","Web-Static-Content","Web-Performance","Web-Stat-Compression","Web-Dyn-Compression","Web-Security","Web-Filtering","Web-Windows-Auth","Web-App-Dev","Web-Net-Ext45","Web-Asp-Net45","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Includes","InkandHandwritingServices","NET-Framework-Features","NET-Framework-Core","NET-HTTP-Activation","NET-Non-HTTP-Activ","NET-WCF-HTTP-Activation45","Windows-Identity-Foundation"
        }
    )

}

NewOfficeWebAppsFarm -OutputPath C:\DSC -ConfigurationData $ConfigurationData

Set-DscLocalConfigurationManager -Path C:\DSC
