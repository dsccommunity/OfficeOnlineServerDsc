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

    Write-Verbose -Message "Getting details of installation of Office Online Server"

    $matchPath = "HKEY_LOCAL_MACHINE\\$($Script:UninstallPath.Replace('\','\\'))" + `
                 "\\$script:InstallKeyPattern"
    $wacPath = Get-ChildItem -Path "HKLM:\$Script:UninstallPath" | Where-Object -FilterScript {
        $_.Name -match $matchPath
    }
    $ensure = "Absent"
    if($null -ne $wacPath)
    {
        $ensure = "Present"
    }
    
    return @{
        Ensure = $ensure
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

    Write-Verbose -Message "Starting installation of Office Online Server"

    $installer = Start-Process -FilePath $Path `
                               -ArgumentList '/config .\files\setupsilent\config.xml' `
                               -Wait `
                               -PassThru

    switch ($installer.ExitCode) {
        0 { 
            Write-Verbose -Message "Installation of Office Online Server succeeded."
         }
        Default {
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
    Write-Verbose -Message "Testing for installation of Office Online Server"
    $result = Get-TargetResource @PSBoundParameters

    return ($result.Ensure -eq $Ensure)
}

Export-ModuleMember -Function *-TargetResource
