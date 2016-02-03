$oOSInstallIsInstalled = New-xDscResourceProperty -Name Installed -Type Boolean -Attribute Read -Description "Specifies if Office Online Server is installed."
$oOSInstallPath        = New-xDscResourceProperty -Name Path -Type String -Attribute Key -Description "Path to setup.exe"

$oOSParams = @{

    Name = 'MSFT_xOfficeOnlineServerInstall'
    Property = $oOSInstallIsInstalled,$oOSInstallPath
    FriendlyName = 'xOfficeOnlineServerInstall'
    ModuleName = 'xOfficeOnlineServer'
    Path = 'C:\Program Files\WindowsPowerShell\Modules\'
}

New-xDscResource @oOSParams