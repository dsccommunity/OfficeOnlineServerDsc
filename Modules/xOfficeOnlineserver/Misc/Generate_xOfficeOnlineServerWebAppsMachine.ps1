$properties = @()
$properties += New-xDscResourceProperty -Name 'Ensure' -Type String -Attribute Write -ValidateSet 'Present','Absent' -Description 'Ensures the server is Present or Absent from the Office Web Apps Farm.'
$properties += New-xDscResourceProperty -Name 'Roles' -Type String[] -Attribute Write -Description 'Specifies one or more server roles, separated by commas, to assign to the new server. If no roles are specified, then the server is assigned all roles.'
$properties += New-xDscResourceProperty -Name 'MachineToJoin' -Type String -Attribute Key  -Description 'Specifies the name of any server that is already a member of the Office Web Apps Server farm.'

$OfficeWebAppsMachineParams = @{

    Name = 'MSFT_xOfficeOnlineServerWebAppsMachine'
    Property = $properties
    FriendlyName = 'xOfficeOnlineServerWebAppsMachine'
    ModuleName = 'xOfficeOnlineServer'
    Path = 'C:\Program Files\WindowsPowerShell\Modules\'
}

New-xDscResource @OfficeWebAppsMachineParams 
