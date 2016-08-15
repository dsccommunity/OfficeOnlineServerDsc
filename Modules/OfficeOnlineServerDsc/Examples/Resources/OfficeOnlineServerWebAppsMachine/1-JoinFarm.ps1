<#
.EXAMPLE
    This example shows how to join a machine to an Office Web Apps farm. This
    shows that the new server will use all roles (it is not recommended to 
    split roles out to dedicated servers for Office Online Server farms of 
    less than 50 servers).
#>

    Configuration Example 
    {
        param()

        Import-DscResource -ModuleName OfficeOnlineServerDsc

        OfficeOnlineServerWebAppsMachine JoinFarm
        {
            MachineToJoin = "office1.contoso.com"
            Roles = "All"
        }
    }
