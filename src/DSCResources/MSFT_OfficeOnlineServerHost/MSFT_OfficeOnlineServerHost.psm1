$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'OfficeOnlineServerDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'OfficeOnlineServerDsc.Util.psm1')

$script:localizedData = Get-LocalizedData -ResourceName (Get-Item -Path $MyInvocation.MyCommand.Path).BaseName

$script:OOSDscRegKey = "HKLM:\SOFTWARE\OOSDsc"

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String[]]
        $AllowList
    )

    Write-Verbose -Message "Retrieving current Office Online Server Farm allow list"

    Confirm-OosDscEnvironmentVariables

    Import-Module -Name OfficeWebApps -ErrorAction Stop -Verbose:$false

    $nullReturn = $PSBoundParameters
    $nullReturn.Ensure = 'Absent'
    $nullReturn.AllowList = @()

    try
    {
        return @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            AllowList        = [Array](Get-OfficeWebAppsHost).AllowList
        }
    }
    catch
    {
        Write-Error -ErrorRecord $_
        return $nullReturn
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String[]]
        $AllowList
    )

    Write-Verbose -Message "Updating Office Online Server Farm allow list"

    Confirm-OosDscEnvironmentVariables

    Import-Module -Name OfficeWebApps -ErrorAction Stop -Verbose:$false

    $CurrentValues = Get-TargetResource @PSBoundParameters

    forEach ($domain in $PSBoundParameters.AllowList)
    {

        if ($Ensure -eq 'Present' -and $domain -notin $CurrentValues.AllowList)
        {
            Write-Verbose -Message "Adding domain '$domain'"
            New-OfficeWebAppsHost -Domain $domain
        }
        elseif ($Ensure -eq 'Absent' -and $domain -in $CurrentValues.AllowList)
        {
            Write-Verbose -Message "Removing domain '$domain'"
            Remove-OfficeWebAppsHost -Domain $domain
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
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String[]]
        $AllowList
    )

    Write-Verbose -Message "Testing Office Online Server Farm allow list"

    Confirm-OosDscEnvironmentVariables

    $PSBoundParameters.Ensure = $Ensure
    $CurrentValues = Get-TargetResource @PSBoundParameters

    $CurrentValues.Remove('Verbose') | Out-Null
    $PSBoundParameters.Remove('Verbose') | Out-Null

    Write-Verbose -Message "Current Values: $(Convert-OosDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-OosDscHashtableToString -Hashtable $PSBoundParameters)"


    forEach ($domain in $PSBoundParameters.AllowList)
    {

        if ($Ensure -eq 'Present' -and $domain -notin $CurrentValues.AllowList)
        {
            return $false
        }

        if ($Ensure -eq 'Absent' -and $domain -in $CurrentValues.AllowList)
        {
            return $false
        }
    }

    return $true
}

Export-ModuleMember -Function *-TargetResource
