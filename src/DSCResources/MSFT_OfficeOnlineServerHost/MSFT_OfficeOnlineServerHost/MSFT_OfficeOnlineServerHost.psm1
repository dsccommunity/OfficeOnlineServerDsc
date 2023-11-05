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
        [System.String[]]
        $Domains

        [Parameter()]
        [System.String[]]
        $DomainsToInclude

        [Parameter()]
        [System.String[]]
        $DomainsToExclude
    )

    Write-Verbose -Message "Retrieving current Office Online Server Farm allow list"

    Import-Module -Name 'OfficeWebApps' -ErrorAction 'Stop' -Verbose:$false

    Confirm-OosDscEnvironmentVariables

    Confirm-OfficeOnlineServerHostPSBoundParameters

    $nullReturn = $PSBoundParameters
    $nullReturn.Domains = @()

    try
    {
        return @{
            IsSingleInstance = 'Yes'
            Domains          = [Array](Get-OfficeWebAppsHost -ErrorAction 'Stop').AllowList
            DomainsToInclude = $DomainsToInclude
            DomainsToExclude = $DomainsToExclude
        }
    }
    catch
    {
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
        [System.String[]]
        $Domains

        [Parameter()]
        [System.String[]]
        $DomainsToInclude

        [Parameter()]
        [System.String[]]
        $DomainsToExclude
    )

    Write-Verbose -Message "Updating Office Online Server Farm allow list"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    # Pass empty array, then all current existing domains are deleted
    if ($Domains -and ($Domains.Count -eq 0))
    {
        forEach ($domain in $CurrentValues.Domains)
        {
            Write-Verbose -Message "Removing domain '$domain'"
            Remove-OfficeWebAppsHost -Domain $domain | Out-Null
        }
    }

    if ($Domains.Count -ge 1)
    {
        forEach ($domain in $PSBoundParameters.Domains)
        {
            if ($domain -notcontains $CurrentValues.Domains)
            {
                Write-Verbose -Message "Adding domain '$domain'"
                New-OfficeWebAppsHost -Domain $domain | Out-Null
            }
        }
    }

    if ($DomainsToExclude)
    {
        forEach ($domain in $PSBoundParameters.DomainsToExclude)
        {
            if ($domain -in $CurrentValues.Domains)
            {
                Write-Verbose -Message "Removing domain '$domain'"
                Remove-OfficeWebAppsHost -Domain $domain | Out-Null
            }
        }
    }

    if ($DomainsToInclude)
    {
        forEach ($domain in $PSBoundParameters.DomainsToInclude)
        {
            if ($domain -notin $CurrentValues.Domains)
            {
                Write-Verbose -Message "Adding domain '$domain'"
                New-OfficeWebAppsHost -Domain $domain | Out-Null
            }
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
        [System.String[]]
        $Domains

        [Parameter()]
        [System.String[]]
        $DomainsToInclude

        [Parameter()]
        [System.String[]]
        $DomainsToExclude
    )

    Write-Verbose -Message "Testing Office Online Server Farm allow list"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $CurrentValues.Remove('Verbose') | Out-Null
    $PSBoundParameters.Remove('Verbose') | Out-Null

    Write-Verbose -Message "Current Values: $(Convert-OosDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-OosDscHashtableToString -Hashtable $PSBoundParameters)"

    if ($Domains)
    {
        return Test-OosDscParameterState -CurrentValues $CurrentValues -DesiredValues $PSBoundParameters -ValuesToCheck 'Domains'
    }

    if ($DomainsToInclude)
    {
        forEach ($domain in $PSBoundParameters.DomainsToInclude)
        {
            if ($domain -notin $CurrentValues.Domains)
            {
                return $false
            }
        }
    }

    if ($DomainsToExclude)
    {
        forEach ($domain in $PSBoundParameters.DomainsToExclude)
        {
            if ($domain -in $CurrentValues.Domains)
            {
                return $false
            }
        }
    }
}

function Confirm-OfficeOnlineServerHostPSBoundParameters
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $Domains

        [Parameter()]
        [System.String[]]
        $DomainsToInclude

        [Parameter()]
        [System.String[]]
        $DomainsToExclude
    )

    if ($Domains -and ($DomainsToInclude -or $DomainsToExclude))
    {
        throw "Cannot use the Domains parameter together with the DomainsToInclude or DomainsToExclude parameters"
    }

    if ($comparison = Compare-Object -ReferenceObject $DomainsToInclude -DifferenceObject $DomainsToExclude -IncludeEqual -ExcludeDifferent)
    {
        throw "DomainsToInclude and DomainsToExclude contains one or more identical values: $($comparision.InputObject -join ', ')"
    }
}

Export-ModuleMember -Function *-TargetResource
