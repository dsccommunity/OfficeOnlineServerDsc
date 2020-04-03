$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'OfficeOnlineServerDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'OfficeOnlineServerDsc.Util.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_OfficeOnlineServerInstallLanguagePack'

$Script:UninstallPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$script:InstallKeyPattern = "Office1(5)|(6).WacServerLpk."

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $BinaryDir,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Language
    )

    Write-Verbose -Message "Getting install status of the $Language Language Pack"

    if ($Ensure -eq "Absent")
    {
        throw "Uninstallation of Language Packs is not currently supported by OfficeOnlineServer Dsc"
    }

    # Check if Binary folder exists
    if (-not(Test-Path -Path $BinaryDir))
    {
        throw "Specified path cannot be found. {$BinaryDir}"
    }

    # Check if setup.exe exists in BinaryDir folder
    $setupExe = Join-Path -Path $BinaryDir -ChildPath "setup.exe"
    if (-not(Test-Path -Path $setupExe))
    {
        throw "Setup.exe cannot be found in {$BinaryDir}"
    }

    Write-Verbose -Message "Checking file status of setup.exe"
    $zone = Get-Item $setupExe -Stream "Zone.Identifier" -EA SilentlyContinue

    if ($null -ne $zone)
    {
        throw ("Setup file is blocked! Please use Unblock-File to unblock the file " + `
                "before continuing.")
    }

    Write-Verbose -Message "Update is for the $Language language"

    $matchPath = "HKEY_LOCAL_MACHINE\\$($Script:UninstallPath.Replace('\','\\'))" + `
        "\\$script:InstallKeyPattern" + $Language
    $wacPath = Get-ChildItem -Path "HKLM:\$Script:UninstallPath" | Where-Object -FilterScript {
        $_.Name -match $matchPath
    }

    if ($null -ne $wacPath)
    {
        Write-Verbose -Message "Language Pack $Language is found"
        return @{
            BinaryDir = $BinaryDir
            Language  = $Language
            Ensure    = "Present"
        }
    }
    else
    {
        Write-Verbose -Message "Language Pack $Language is NOT found"
        return @{
            BinaryDir = $BinaryDir
            Language  = $Language
            Ensure    = "Absent"
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
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $BinaryDir,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Language
    )

    Write-Verbose -Message "Setting install status of Office Online Language Pack"

    if ($Ensure -eq "Absent")
    {
        throw [Exception] ("OfficeOnlineServerDsc does not support uninstalling " + `
                "Language Packs. Please remove this manually.")
    }

    # Check if Binary folder exists
    if (-not(Test-Path -Path $BinaryDir))
    {
        throw "Specified path cannot be found. {$BinaryDir}"
    }

    # Check if setup.exe exists in BinaryDir folder
    $setupExe = Join-Path -Path $BinaryDir -ChildPath "setup.exe"
    if (-not(Test-Path -Path $setupExe))
    {
        throw "Setup.exe cannot be found in {$BinaryDir}"
    }

    Write-Verbose -Message $script:localizedData.CheckingFileStatus
    $checkBlockedFile = $true
    if (Split-Path -Path $setupExe -IsAbsolute)
    {
        $driveLetter = (Split-Path -Path $setupExe -Qualifier).TrimEnd(":")
        Write-Verbose -Message "BinaryDir refers to drive $driveLetter"

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
        try
        {
            $zone = Get-Item -Path $setupExe -Stream "Zone.Identifier" -EA SilentlyContinue
        }
        catch
        {
            Write-Verbose -Message $script:localizedData.ErrorReadingFileStream
        }
        if ($null -ne $zone)
        {
            throw ("Setup file is blocked! Please use 'Unblock-File -Path " + `
                    "$setupExe' to unblock the file before continuing.")
        }
        Write-Verbose -Message $script:localizedData.FileNotBlocked
    }

    Write-Verbose -Message $script:localizedData.CheckIfUNC
    $uncInstall = $false
    if ($BinaryDir.StartsWith("\\"))
    {
        Write-Verbose -Message $script:localizedData.PathIsUNC

        $uncInstall = $true

        $null = $setupexe -match "\\\\(.*?)\\.*"
        $serverName = $Matches[1]

        Set-OosDscZoneMap -Server $serverName
    }

    Write-Verbose -Message $script:localizedData.InstallingLanguagePack
    $installer = Start-Process -FilePath $setupExe `
        -ArgumentList '/config .\files\setupsilent\config.xml' `
        -Wait `
        -PassThru

    if ($uncInstall -eq $true)
    {
        Write-Verbose -Message $script:localizedData.RemoveUNCPath
        Remove-OosDscZoneMap -ServerName $serverName
    }

    switch ($installer.ExitCode)
    {
        0
        {
            Write-Verbose -Message $script:localizedData.InstallationSucceeded
        }
        17022
        {
            Write-Verbose -Message $script:localizedData.RebootRequired
            $global:DSCMachineStatus = 1
        }
        Default
        {
            throw "Office Online Server Language Pack install failed, exit code was $($installer.ExitCode)"
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
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $BinaryDir,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Language
    )

    Write-Verbose -Message "Testing install status of Office Online Server $Language Language Pack"

    if ($Ensure -eq "Absent")
    {
        throw [Exception] ("OfficeOnlineServerDsc does not support uninstalling Office Online Server " + `
                "Language Packs. Please remove this manually.")
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-OosDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-OosDscHashtableToString -Hashtable $PSBoundParameters)"

    if ($CurrentValues.Ensure -eq $Ensure)
    {
        Write-Verbose -Message "Language Pack $Language is already installed on the server"
        return $true
    }
    else
    {
        return $false
    }
}

Export-ModuleMember -Function *-TargetResource
