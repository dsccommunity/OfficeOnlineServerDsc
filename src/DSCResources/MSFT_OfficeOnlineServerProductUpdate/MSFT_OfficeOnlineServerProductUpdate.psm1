$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'OfficeOnlineServerDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'OfficeOnlineServerDsc.Util.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_OfficeOnlineServerProductUpdate'

$script:OOSDscRegKey = "HKLM:\SOFTWARE\OOSDsc"

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupFile,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Servers,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    if ($Ensure -eq "Absent")
    {
        throw [Exception] "Office Online Server does not support uninstalling updates."
    }

    Write-Verbose -Message "Getting install status of OOS binaries"

    Write-Verbose -Message $script:localizedData.CheckIfFileExists
    if (-not(Test-Path -Path $SetupFile))
    {
        throw "Setup file cannot be found: {$SetupFile}"
    }

    if ($Servers -notcontains $env:COMPUTERNAME)
    {
        throw "Parameter Servers should contain the current server name {$env:COMPUTERNAME}"
    }

    Write-Verbose -Message "Checking file status of $SetupFile"
    $checkBlockedFile = $true
    if (Split-Path -Path $SetupFile -IsAbsolute)
    {
        $driveLetter = (Split-Path -Path $SetupFile -Qualifier).TrimEnd(":")
        Write-Verbose -Message "SetupFile refers to drive $driveLetter"

        $volume = Get-Volume -DriveLetter $driveLetter -ErrorAction SilentlyContinue
        if ($null -ne $volume)
        {
            if ($volume.DriveType -ne "CD-ROM")
            {
                Write-Verbose -Message $script:localizedData.VolumeIsFixedDrive
            }
            else
            {
                Write-Verbose -Message $script:localizedData.VolumeIsCDDrive
                $checkBlockedFile = $false
            }
        }
        else
        {
            Write-Verbose -Message $script:localizedData.VolumeNotFound
        }
    }

    if ($checkBlockedFile -eq $true)
    {
        Write-Verbose -Message $script:localizedData.CheckingStatus
        $zone = Get-Item -Path $SetupFile -Stream "Zone.Identifier" -EA SilentlyContinue

        if ($null -ne $zone)
        {
            throw ("Setup file is blocked! Please use 'Unblock-File -Path $SetupFile' " + `
                    "to unblock the file before continuing.")
        }
        Write-Verbose -Message $script:localizedData.FileNotBlocked
    }

    Write-Verbose -Message $script:localizedData.GetFileInfo
    $setupFileInfo = Get-ItemProperty -Path $SetupFile
    $fileVersion = $setupFileInfo.VersionInfo.FileVersion

    Write-Verbose -Message "Update has version $fileVersion"
    $fileVersionInfo = New-Object -TypeName System.Version -ArgumentList $fileVersion

    Write-Verbose -Message $script:localizedData.GetOOSInfo
    $OfficeVersionInfoFile = "C:\ProgramData\Microsoft\OfficeWebApps\Data\local\OfficeVersion.inc"
    if ((Test-Path -Path $OfficeVersionInfoFile) -eq $false)
    {
        $OfficeVersionInfoFile = "C:\Program Files\Microsoft Office Web Apps\AgentManager\OfficeVersion.inc"
        if ((Test-Path -Path $OfficeVersionInfoFile) -eq $false)
        {
            throw "Cannot find file $OfficeVersionInfoFile"
        }
    }

    $OfficeVersionInfo = Get-Content -Path $OfficeVersionInfoFile -Raw
    if ($OfficeVersionInfo -match "RMJ = ([0-9]*)\r*\nRMM = ([0-9]*)\r*\nRUP = ([0-9]*)\r*\nRPR = ([0-9]*)")
    {
        [System.Version]$versionInfo = $matches[1] + "." + $matches[2] + "." + $matches[3] + "." + $matches[4]
    }
    else
    {
        throw "Cannot read Version information from file $OfficeVersionInfoFile"
    }

    Write-Verbose -Message "The version of Office Online Server is $($versionInfo)"
    if ($versionInfo -lt $fileVersionInfo)
    {
        # Version of OfficeOnlineServer is lower than the patch version. Patch is not installed.
        return @{
            SetupFile = $SetupFile
            Ensure    = "Absent"
        }
    }
    else
    {
        # Version of OfficeOnlineServer is equal or greater than the patch version. Patch is installed.
        return @{
            SetupFile = $SetupFile
            Ensure    = "Present"
        }
    }
}

function Set-TargetResource
{
    # Supressing the global variable use to allow passing DSC the reboot message
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupFile,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Servers,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting install status of OOS Update binaries"

    if ($Ensure -eq "Absent")
    {
        throw [Exception] "Office Online Server does not support uninstalling updates."
    }

    Write-Verbose -Message "Check if the setup file exists"
    if (-not(Test-Path -Path $SetupFile))
    {
        throw "Setup file cannot be found: {$SetupFile}"
    }

    if ($Servers -notcontains $env:COMPUTERNAME)
    {
        throw "Parameter Servers should contain the current server name {$env:COMPUTERNAME}"
    }

    $OfficeVersionInfoFile = "C:\ProgramData\Microsoft\OfficeWebApps\Data\local\OfficeVersion.inc"
    if ((Test-Path -Path $OfficeVersionInfoFile) -eq $false)
    {
        $OfficeVersionInfoFile = "C:\Program Files\Microsoft Office Web Apps\AgentManager\OfficeVersion.inc"
        if ((Test-Path -Path $OfficeVersionInfoFile) -eq $false)
        {
            throw "Cannot find file $OfficeVersionInfoFile. Is Office Online Server installed?"
        }
    }

    Write-Verbose -Message "Checking file status of $SetupFile"
    $checkBlockedFile = $true
    if (Split-Path -Path $SetupFile -IsAbsolute)
    {
        $driveLetter = (Split-Path -Path $SetupFile -Qualifier).TrimEnd(":")
        Write-Verbose -Message "SetupFile refers to drive $driveLetter"

        $volume = Get-Volume -DriveLetter $driveLetter -ErrorAction SilentlyContinue
        if ($null -ne $volume)
        {
            if ($volume.DriveType -ne "CD-ROM")
            {
                Write-Verbose -Message $script:localizedData.VolumeIsFixedDrive
            }
            else
            {
                Write-Verbose -Message $script:localizedData.VolumeIsCDDrive
                $checkBlockedFile = $false
            }
        }
        else
        {
            Write-Verbose -Message $script:localizedData.VolumeNotFound
        }
    }

    if ($checkBlockedFile -eq $true)
    {
        Write-Verbose -Message $script:localizedData.CheckingStatus
        $zone = Get-Item -Path $SetupFile -Stream "Zone.Identifier" -EA SilentlyContinue

        if ($null -ne $zone)
        {
            throw ("Setup file is blocked! Please use 'Unblock-File -Path $SetupFile' " + `
                    "to unblock the file before continuing.")
        }
        Write-Verbose -Message $script:localizedData.FileNotBlocked
    }

    Write-Verbose -Message $script:localizedData.GetFileInfo
    $setupFileInfo = Get-ItemProperty -Path $SetupFile
    $fileVersion = $setupFileInfo.VersionInfo.FileVersion

    Write-Verbose -Message "Update has version $fileVersion"
    $PatchVersion = New-Object -TypeName System.Version -ArgumentList $fileVersion

    Write-Verbose -Message $script:localizedData.GetOOSInfo
    $serversInfo = Get-ServerInfo -Servers $Servers

    # Get current server info
    $currentServer = $serversInfo | Where-Object -FilterScript { $_.Name -eq $env:COMPUTERNAME }

    if ($null -ne $currentServer.MasterMachine)
    {
        if ($env:COMPUTERNAME -eq $currentServer.MasterMachine)
        {
            # Server is MasterMachine
            if ($currentServer.Machines.Count -gt 1)
            {
                Write-Verbose -Message "There are $($currentServer.Machines.Count - 1) more servers in the farm."
                Write-Verbose -Message "Waiting for all other servers to be patched first."

                $count = 0
                $maxcount = 30
                $machinesCount = (Get-OfficeWebAppsFarm).Machines.Count
                while (($count -lt $maxCount) -and ($machinesCount -gt 1))
                {
                    Write-Verbose -Message ("$([DateTime]::Now.ToShortTimeString()) - " + `
                            "Waiting for other OOS servers to be patched first " + `
                            "(waited $count of $maxCount minutes)")
                    Write-Verbose -Message "$($machinesCount -1) other servers still need to be patched"
                    Start-Sleep -Seconds 60

                    $machinesCount = (Get-OfficeWebAppsFarm).Machines.Count
                    $count++
                }

                if ($machinesCount -gt 1)
                {
                    throw ("[ERROR] Cannot complete patching. Other servers need to be patched first. " + `
                            "Waited $maxcount minutes for other servers complete patching.")
                }
            }

            Write-Verbose -Message "Current server is the last server in the OOS farm"
            Write-Verbose -Message "Remove server from OOS farm and install OOS patch"

            # Determine new MasterMachine (one of the already patched servers)
            $patchedMachines = $serversInfo | Where-Object -FilterScript { $_.Version -eq $PatchVersion }
            if ($null -eq $patchedMachines)
            {
                # No other machines are patched yet, probably single server. Set current machine to newMaster
                $newMaster = $env:COMPUTERNAME
            }
            else
            {
                # Determine newMaster from other machines
                $newMaster = $patchedMachines.MasterMachine | Sort-Object | Select-Object -Unique
                if ($newMaster -is [System.Array])
                {
                    Write-Verbose -Message "WARNING: Multiple masters found"
                    $newMaster = $newMaster | Select-Object -First
                }
                elseif ($null -eq $newMaster)
                {
                    throw "Unable to determine new master. Cannot continue patching server."
                }
            }
            Write-Verbose -Message "Determined the following server to be the new MasterMachine {$newMaster}"

            if ($currentServer.Version -lt $PatchVersion)
            {
                Write-Verbose -Message "Current server is running an older path level, patch required"

                Set-OOSDscRegKeys -NewMaster $newMaster -Config $currentServer.Config -Roles $currentServer.Roles

                Write-Verbose -Message "Removing server from OOS farm"
                Remove-OfficeWebAppsMachine

                Write-Verbose -Message "Installing OOS Patch"
                Install-OOSDscPatch -SetupFile $setupFile

                Write-Verbose -Message "Rebooting server to complete installation"
                $global:DSCMachineStatus = 1
            }
            else
            {
                Write-Verbose -Message "Server already on correct patch level"
            }
        }
        else
        {
            Write-Verbose -Message "Current server is not the MasterMachine"

            # Determine new MasterMachine (one of the already patched servers)
            $patchedMachines = $serversInfo | Where-Object -FilterScript { $_.Version -eq $PatchVersion }
            if ($null -eq $patchedMachines)
            {
                # No other machines are patched yet, probably single server. Set current machine to newMaster
                $newMaster = $env:COMPUTERNAME
            }
            else
            {
                # Determine newMaster from other machines
                $newMaster = $patchedMachines.NewMaster | Sort-Object | Select-Object -Unique
                if ($newMaster -is [System.Array])
                {
                    Write-Verbose -Message "WARNING: Multiple masters found"
                    $newMaster = $newMaster | Select-Object -First
                }
            }
            Write-Verbose -Message "Determined the following server to be the new MasterMachine {$newMaster}"

            if ($currentServer.Version -lt $PatchVersion)
            {
                Write-Output "Current version is running an older path level, patch required"

                Set-OOSDscRegKeys -NewMaster $newMaster -Config $currentServer.Config -Roles $currentServer.Roles

                Write-Verbose -Message "Removing server from OOS farm"
                Remove-OfficeWebAppsMachine

                Write-Verbose -Message "Installing OOS Patch"
                Install-OOSDscPatch -SetupFile $setupFile

                Write-Verbose -Message "Rebooting server to complete installation"
                $global:DSCMachineStatus = 1
            }
            else
            {
                Write-Verbose -Message "Server already on correct patch level"
            }

        }
    }
    else
    {
        # Current server is not joined to a farm
        $resume = $false

        if (Test-Path -Path $OOSDscRegKey)
        {
            # Get NewMaster item
            $key = Get-Item -Path $OOSDscRegKey
            $state = $key.GetValue("State")

            if ($state -eq "Patching")
            {
                $resume = $true
            }
        }

        # Check if the patch is already installed
        if ($resume -eq $false)
        {
            Write-Verbose -Message "Server does not have the patch installed yet."
            Write-Verbose -Message "Probably new server which is not yet joined to a farm."

            Write-Verbose -Message "Installing OOS Patch"
            Install-OOSDscPatch -SetupFile $setupFile

            Write-Verbose -Message "Rebooting server to complete installation"
            $global:DSCMachineStatus = 1
        }
        else
        {
            Write-Verbose -Message "Server is continuing after the required reboot."

            Write-Verbose -Message "Check if current machine needs to create new farm"
            if ($currentServer.Name -eq $currentServer.NewMaster)
            {
                Write-Verbose -Message "This server is the new Master and needs to create a new farm"

                Write-Verbose -Message "Read required config from registry"
                $config = $key.GetValue("Config")

                $objParams = $config | ConvertFrom-Json
                $params = @{ }
                $objParams | Get-Member -MemberType *Property | ForEach-Object -Process {
                    if ([string]::IsNullOrEmpty($objParams.($_.name)) -eq $false)
                    {
                        $params.($_.name) = $objParams.($_.name)
                    }
                }

                Write-Verbose -Message "Create new farm based on the old config"
                $null = New-OfficeWebAppsFarm @params -Force
            }
            else
            {
                Write-Verbose -Message "This server needs to join an existing farm"

                Write-Verbose -Message "Read server roles from registry"
                $roles = $key.GetValue("Roles") -split ","

                $domain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
                Write-Verbose -Message "Creating new farm with Master server $($currentServer.NewMaster).$domain and roles $($roles -join ", ")"
                New-OfficeWebAppsMachine -MachineToJoin "$($currentServer.NewMaster).$domain" -Roles $roles
            }

            Write-Verbose -Message "Cleaning up registry data"
            Remove-Item -Path $OOSDscRegKey -ErrorAction SilentlyContinue
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupFile,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Servers,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing install status of OOS Update binaries"

    $PSBoundParameters.Ensure = $Ensure

    if ($Ensure -eq "Absent")
    {
        throw [Exception] "Office Online Server does not support uninstalling updates."
        return
    }

    # Check if server is continuing after a reboot
    if (Test-Path -Path $OOSDscRegKey)
    {
        $key = Get-Item -Path $OOSDscRegKey
        $state = $key.GetValue("State")

        if ($state -eq "Patching")
        {
            Write-Verbose -Message "Server continuing after required reboot after patching."
            Write-Verbose -Message "Returning False."
            return $false
        }
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-OosDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-OosDscHashtableToString -Hashtable $PSBoundParameters)"

    return Test-OosDscParameterState -CurrentValues $CurrentValues `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck @("Ensure")
}

Export-ModuleMember -Function *-TargetResource

function Get-ServerInfo
{
    [OutputType([System.Array])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Servers
    )

    $serversInfo = @()
    foreach ($server in $Servers)
    {
        $serversInfo += Invoke-Command -ComputerName $server -ScriptBlock {
            $returnval = @{
                Name = $env:COMPUTERNAME
            }

            $OfficeVersionInfoFile = "C:\ProgramData\Microsoft\OfficeWebApps\Data\local\OfficeVersion.inc"

            if ((Test-Path -Path $OfficeVersionInfoFile) -eq $false)
            {
                $OfficeVersionInfoFile = "C:\Program Files\Microsoft Office Web Apps\AgentManager\OfficeVersion.inc"
            }

            if ((Test-Path -Path $OfficeVersionInfoFile) -eq $true)
            {
                $OfficeVersionInfo = Get-Content -Path $OfficeVersionInfoFile -Raw
                if ($OfficeVersionInfo -match "RMJ = ([0-9]*)\r\nRMM = ([0-9]*)\r\nRUP = ([0-9]*)\r\nRPR = ([0-9]*)")
                {
                    [System.Version]$versionInfo = $matches[1] + "." + $matches[2] + "." + $matches[3] + "." + $matches[4]
                }
                else
                {
                    [System.Version]$versionInfo = "0.0.0.0"
                }
            }
            else
            {
                [System.Version]$versionInfo = "0.0.0.0"
            }
            $returnval.Version = $versionInfo

            try
            {
                $oosFarm = Get-OfficeWebAppsFarm -ErrorAction SilentlyContinue
                if ($null -ne $oosFarm)
                {
                    $oosMachine = Get-OfficeWebAppsMachine
                    $returnval.Machines = $oosFarm.Machines.MachineName
                    $returnval.MasterMachine = $oosMachine.MasterMachineName
                    $returnval.Roles = $oosMachine.Roles -join ","

                    # Retrieving OOS Farm properties and convert to JSON
                    $objProps = $oosFarm | Select-Object -Property * -ExcludeProperty ExcelEnableCrossForestKerberosAuthentication, Machines, OfficeAddinEnabled, OnlinePictureEnabled, OnlineVideoEnabled
                    $jsonProps = $objProps | ConvertTo-Json

                    $returnval.Config = $jsonProps
                }
                else
                {
                    $returnval.Machines = $null
                    $returnval.MasterMachine = $null
                }
            }
            catch
            {
                $returnval.Machines = $null
                $returnval.MasterMachine = $null
            }

            # Check if NewMaster OOSDscRegKey has been created
            $OOSDscRegKey = "HKLM:\SOFTWARE\OOSDsc"
            if (Test-Path -Path $OOSDscRegKey)
            {
                # Get NewMaster item
                $key = Get-Item $OOSDscRegKey
                $returnval.NewMaster = $key.GetValue("NewMaster")
            }
            else
            {
                $returnval.NewMaster = $null
            }

            return $returnval
        }
    }

    return $serversInfo
}

function Set-OOSDscRegKeys
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $NewMaster,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Config,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Roles
    )

    # Testing OOSDsc reg key
    if ((Test-Path -Path $OOSDscRegKey) -eq $false)
    {
        $null = New-Item -Path $OOSDscRegKey
    }

    # Set "Patching" registry key
    $null = New-ItemProperty -Path $OOSDscRegKey -Name State -PropertyType String -Value "Patching" -Force

    # Set "NewMaster" registry key to $newMaster
    $null = New-ItemProperty -Path $OOSDscRegKey -Name NewMaster -PropertyType String -Value $NewMaster -Force

    # Set "Config" registry key to $newMaster
    $null = New-ItemProperty -Path $OOSDscRegKey -Name Config -PropertyType String -Value $Config -Force

    # Set "Roles" registry key to $newMaster
    $null = New-ItemProperty -Path $OOSDscRegKey -Name Roles -PropertyType String -Value $Roles -Force

}

function Install-OOSDscPatch
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupFile
    )

    Write-Verbose -Message "Beginning installation of the OOS update"

    Write-Verbose -Message $script:localizedData.CheckIfUNC
    $uncInstall = $false
    if ($SetupFile.StartsWith("\\"))
    {
        Write-Verbose -Message $script:localizedData.PathIsUNC

        $uncInstall = $true

        if ($SetupFile -match "\\\\(.*?)\\.*")
        {
            $serverName = $Matches[1]
        }
        else
        {
            throw "Cannot extract servername from UNC path. Check if it is in the correct format."
        }

        Set-OosDscZoneMap -Server $serverName
    }

    $setup = Start-Process -FilePath $SetupFile `
        -ArgumentList "/quiet /passive" `
        -Wait `
        -PassThru

    if ($uncInstall -eq $true)
    {
        Write-Verbose -Message $script:localizedData.RemoveUNCPath
        Remove-OosDscZoneMap -ServerName $serverName
    }

    # Error codes: https://aka.ms/installerrorcodes
    switch ($setup.ExitCode)
    {
        0
        {
            Write-Verbose -Message $script:localizedData.InstallSucceeded
        }
        17022
        {
            Write-Verbose -Message $script:localizedData.RebootRequired
        }
        17025
        {
            Write-Verbose -Message $script:localizedData.AlreadyInstalled
        }
        Default
        {
            throw ("Office Online Server update install failed, exit code was $($setup.ExitCode). " + `
                    "Error codes can be found at https://aka.ms/installerrorcodes")
        }
    }
}
