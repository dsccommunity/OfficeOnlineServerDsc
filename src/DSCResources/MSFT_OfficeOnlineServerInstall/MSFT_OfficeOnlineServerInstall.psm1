$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'OfficeOnlineServerDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'OfficeOnlineServerDsc.Util.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_OfficeOnlineServerInstall'

$Script:UninstallPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$script:InstallKeyPattern = "Office1(5)|(6).WacServer"

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet("Present", "Absent")]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    if ($Ensure -eq "Absent")
    {
        throw "Uninstallation is not supported by OfficeOnlineServer Dsc"
    }

    Write-Verbose -Message "Getting details of installation of Office Online Server"

    # Check if Binary folder exists
    if (-not(Test-Path -Path $Path))
    {
        throw "Specified path cannot be found. {$Path}"
    }

    Write-Verbose -Message "Checking file status of $Path"
    $checkBlockedFile = $true
    if (Split-Path -Path $Path -IsAbsolute)
    {
        $driveLetter = (Split-Path -Path $Path -Qualifier).TrimEnd(":")
        Write-Verbose -Message "Path refers to drive $driveLetter"

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
        Write-Verbose -Message "Checking status now"
        try
        {
            $zone = Get-Item -Path $Path -Stream "Zone.Identifier" -EA SilentlyContinue
        }
        catch
        {
            Write-Verbose -Message $script:localizedData.ErrorReadingFileStream
        }
        if ($null -ne $zone)
        {
            throw ("Setup file is blocked! Please use 'Unblock-File -Path " + `
                    "$Path' to unblock the file before continuing.")
        }
        Write-Verbose -Message $script:localizedData.FileNotBlocked
    }

    $matchPath = "HKEY_LOCAL_MACHINE\\$($Script:UninstallPath.Replace('\','\\'))" + `
        "\\$script:InstallKeyPattern"
    $wacPath = Get-ChildItem -Path "HKLM:\$Script:UninstallPath" | Where-Object -FilterScript {
        $_.Name -match $matchPath
    }

    $localEnsure = "Absent"
    if ($null -ne $wacPath)
    {
        $localEnsure = "Present"
    }

    return @{
        Ensure = $localEnsure
        Path   = $Path
    }
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet("Present", "Absent")]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    if ($Ensure -eq "Absent")
    {
        throw "Uninstallation is not supported by OfficeOnlineServer Dsc"
    }

    Write-Verbose -Message "Starting installation of Office Online Server"

    # Check if Binary folder exists
    if (-not(Test-Path -Path $Path))
    {
        throw "Specified path cannot be found. {$Path}"
    }

    Write-Verbose -Message "Checking file status of $Path"
    $checkBlockedFile = $true
    if (Split-Path -Path $Path -IsAbsolute)
    {
        $driveLetter = (Split-Path -Path $Path -Qualifier).TrimEnd(":")
        Write-Verbose -Message "Path refers to drive $driveLetter"

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
        Write-Verbose -Message "Checking status now"
        try
        {
            $zone = Get-Item -Path $Path -Stream "Zone.Identifier" -EA SilentlyContinue
        }
        catch
        {
            Write-Verbose -Message $script:localizedData.ErrorReadingFileStream
        }
        if ($null -ne $zone)
        {
            throw ("Setup file is blocked! Please use 'Unblock-File -Path " + `
                    "$Path' to unblock the file before continuing.")
        }
        Write-Verbose -Message $script:localizedData.FileNotBlocked
    }

    Write-Verbose -Message $script:localizedData.CheckForUNC
    $uncInstall = $false
    if ($Path.StartsWith("\\"))
    {
        Write-Verbose -Message $script:localizedData.PathIsUNC

        $uncInstall = $true

        $null = $Path -match "\\\\(.*?)\\.*"
        $serverName = $Matches[1]

        Set-OosDscZoneMap -Server $serverName
    }

    $installer = Start-Process -FilePath $Path `
        -ArgumentList '/config .\files\setupsilent\config.xml' `
        -Wait `
        -PassThru

    if ($uncInstall -eq $true)
    {
        Write-Verbose -Message $script:localizedData.RemoveUNCPath
        Remove-OosDscZoneMap -ServerName $serverName
    }

    # Exit codes: https://docs.microsoft.com/en-us/windows/desktop/msi/error-codes
    switch ($installer.ExitCode)
    {
        0
        {
            Write-Verbose -Message $script:localizedData.InstallationSucceeded
        }
        3010
        {
            Write-Verbose -Message $script:localizedData.RebootRequired
            $global:DSCMachineStatus = 1
        }
        Default
        {
            throw ("Office Online Server installation failed. Exit code " + `
                    "'$($installer.ExitCode)' was returned. Check " + `
                    "$($env:TEMP)\Wac Server Setup.log for further information")
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
        [ValidateSet("Present", "Absent")]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    if ($Ensure -eq "Absent")
    {
        throw "Uninstallation is not supported by OfficeOnlineServer Dsc"
    }

    Write-Verbose -Message "Testing for installation of Office Online Server"
    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-OosDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-OosDscHashtableToString -Hashtable $PSBoundParameters)"

    return ($CurrentValues.Ensure -eq $Ensure)
}

Export-ModuleMember -Function *-TargetResource
