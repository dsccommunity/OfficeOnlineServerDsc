$Script:UninstallPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$script:InstallKeyPattern = "Office1(5)|(6).WacServer"

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet("Present", "Absent")]
        $Ensure,

        [parameter(Mandatory = $true)]
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

    Write-Verbose -Message "Checking file status of setup.exe"
    $zone = Get-Item $Path -Stream "Zone.Identifier" -EA SilentlyContinue

    if ($null -ne $zone)
    {
        throw ("Setup file is blocked! Please use Unblock-File to unblock the file " + `
               "before continuing.")
    }

    $matchPath = "HKEY_LOCAL_MACHINE\\$($Script:UninstallPath.Replace('\','\\'))" + `
                 "\\$script:InstallKeyPattern"
    $wacPath = Get-ChildItem -Path "HKLM:\$Script:UninstallPath" | Where-Object -FilterScript {
        $_.Name -match $matchPath
    }

    $localEnsure = "Absent"
    if($null -ne $wacPath)
    {
        $localEnsure = "Present"
    }

    return @{
        Ensure = $localEnsure
        Path = $Path
    }
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet("Present", "Absent")]
        $Ensure,

        [parameter(Mandatory = $true)]
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

    Write-Verbose -Message "Checking file status of setup.exe"
    $zone = Get-Item $Path -Stream "Zone.Identifier" -EA SilentlyContinue

    if ($null -ne $zone)
    {
        throw ("Setup file is blocked! Please use Unblock-File to unblock the file " + `
               "before continuing.")
    }

    Write-Verbose -Message "Checking if Path is a UNC path"
    $uncInstall = $false
    if ($Path.StartsWith("\\"))
    {
        Write-Verbose -Message "Specified Path is UNC path. Adding path to Local Intranet Zone"

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
        Write-Verbose -Message "Removing added path from the Local Intranet Zone"
        Remove-OosDscZoneMap -ServerName $serverName
    }

    # Exit codes: https://docs.microsoft.com/en-us/windows/desktop/msi/error-codes
    switch ($installer.ExitCode) {
        0
        {
            Write-Verbose -Message "Installation of Office Online Server succeeded."
        }
        3010
        {
            Write-Verbose -Message "SharePoint binary installation complete, but reboot is required"
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
        [parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet("Present", "Absent")]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    if ($Ensure -eq "Absent")
    {
        throw "Uninstallation is not supported by OfficeOnlineServer Dsc"
    }

    Write-Verbose -Message "Testing for installation of Office Online Server"
    $result = Get-TargetResource @PSBoundParameters

    return ($result.Ensure -eq $Ensure)
}

Export-ModuleMember -Function *-TargetResource
