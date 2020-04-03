$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'OfficeOnlineServerDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'OfficeOnlineServerDsc.Util.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_OfficeOnlineServerMachine'

$script:OOSDscRegKey = "HKLM:\SOFTWARE\OOSDsc"

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String[]]
        $Roles,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MachineToJoin
    )

    Write-Verbose -Message "Getting settings for local Office Online Server"

    Confirm-OosDscEnvironmentVariables

    Import-Module -Name OfficeWebApps -ErrorAction Stop

    $officeWebAppsMachine = $null

    try
    {
        $officeWebAppsMachine = Get-OfficeWebAppsMachine
    }
    catch
    {
        # catch when not a part of the farm and redirect output to returned hash table
        $notInFarmError = "It does not appear that this machine is part of an " + `
            "(Office Online)|(Office Web Apps) Server farm\."
        if ($_.toString() -match $notInFarmError)
        {
            Write-Verbose -Message $script:localizedData.NotApartOfAFarm
        }
        else
        {
            throw
        }
    }

    if ($null -eq $officeWebAppsMachine)
    {
        $returnValue = @{
            Ensure        = "Absent"
            Roles         = $null
            MachineToJoin = $null
        }
    }
    else
    {
        $returnValue = @{
            Ensure        = "Present"
            Roles         = [System.String[]]$officeWebAppsMachine.Roles
            MachineToJoin = [System.String]$officeWebAppsMachine.MasterMachineName
        }
    }

    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String[]]
        $Roles,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MachineToJoin
    )

    Write-Verbose -Message "Updating settings for local Office Online Server"

    Confirm-OosDscEnvironmentVariables

    Import-Module -Name OfficeWebApps -ErrorAction Stop

    if ($Ensure -eq "Absent")
    {
        Remove-OfficeWebAppsMachine

        Write-Verbose -Message $script:localizedData.RemoveAppMachine
    }
    else
    {
        # Due to issues with Set-OfficeWebAppsMachine not changing machine roles,
        # always remove the machine and re-add.

        try
        {
            Remove-OfficeWebAppsMachine -ErrorAction Stop
        }
        catch
        {
            Write-Verbose -Message $script:localizedData.FailedRemove
        }

        if ($null -eq $Roles)
        {
            $Roles = @("All")
        }

        $null = New-OfficeWebAppsMachine -MachineToJoin $MachineToJoin -Roles $Roles

        Write-Verbose -Message $script:localizedData.SetAppMachine
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String[]]
        $Roles,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MachineToJoin
    )

    Write-Verbose -Message "Testing settings for local Office Online Server"

    Confirm-OosDscEnvironmentVariables

    # Check if server is continuing after a patch install reboot
    if (Test-Path -Path $OOSDscRegKey)
    {
        $key = Get-Item -Path $OOSDscRegKey
        $state = $key.GetValue("State")

        if ($state -eq "Patching")
        {
            Write-Verbose -Message "Server continuing after a patch reboot. Farm join not required."
            Write-Verbose -Message "Returning True to prevent issues."
            return $true
        }
    }

    $CurrentValues = Get-TargetResource -MachineToJoin $MachineToJoin

    Write-Verbose -Message "Current Values: $(Convert-OosDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-OosDscHashtableToString -Hashtable $PSBoundParameters)"

    if ($null -eq $Roles)
    {
        $Roles = @("All")
    }

    if ($null -eq $CurrentValues.Roles)
    {
        $roleCompare = $null
    }
    else
    {
        $roleCompare = Compare-Object -ReferenceObject $CurrentValues.Roles -DifferenceObject $Roles
    }

    if (($CurrentValues.Ensure -eq "Present") `
            -and ($Ensure -eq "Present") `
            -and ( $null -eq $roleCompare))
    {
        # If present and all value match return true
        return $true
    }
    elseif (($CurrentValues.Ensure -eq "Absent") -and ($Ensure -eq "Absent"))
    {
        # if absent no need to check all values
        return $true
    }
    else
    {
        return $false
    }
}

Export-ModuleMember -Function *-TargetResource

