configuration WebAppMachine
{
    Import-DscResource -ModuleName xOfficeOnlineServer

    node localhost
    {
        xOfficeOnlineServerWebAppsMachine WebAppMachine
        {
            Ensure = "Present"
            MachineToJoin = "WIN-S40H6PF9JJN"
            Roles = "All"
        }
    }
}

WebAppMachine -OutputPath C:\DSC
Start-DscConfiguration -Path C:\DSC -Wait -Verbose -Force
