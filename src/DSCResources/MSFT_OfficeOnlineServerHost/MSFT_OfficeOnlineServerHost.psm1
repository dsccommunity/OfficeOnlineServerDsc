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
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $Domains
    )

    Write-Verbose -Message "Retrieving Office Online Server Farm host allow list"

    Import-Module -Name 'OfficeWebApps' -ErrorAction 'Stop' -Verbose:$false

    Confirm-OosDscEnvironmentVariables

    Test-OfficeOnlineServerHostPSBoundParameters @PSBoundParameters

    $nullReturn = $PSBoundParameters
    $nullReturn.Domains = @()

    try
    {
        return @{
            IsSingleInstance = 'Yes'
            Domains          = [Array](Get-OfficeWebAppsHost -ErrorAction 'Stop').AllowList
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
        $Domains,

        [Parameter()]
        [System.String[]]
        $DomainsToInclude,

        [Parameter()]
        [System.String[]]
        $DomainsToExclude
    )

    Write-Verbose -Message "Updating Office Online Server Farm host allow list"

    Import-Module -Name 'OfficeWebApps' -ErrorAction 'Stop' -Verbose:$false

    Confirm-OosDscEnvironmentVariables

    Test-OfficeOnlineServerHostPSBoundParameters @PSBoundParameters

    $CurrentValues = Get-TargetResource -Domains $Domains -IsSingleInstance 'Yes'

    if ($PSBoundParameters.ContainsKey('Domains'))
    {
        # Pass empty array, then all existing domains will be deleted
        if ($null -eq $Domains)
        {
            $PSBoundParameters.Add('DomainsToExclude', $CurrentValues.Domains) | Out-Null

            # Compares current vs target domains and decided wich ones to keep
        }
        else
        {

            $PSBoundParameters.Add('DomainsToInclude', $Domains) | Out-Null

            $domainsToBeExcluded = $CurrentValues.Domains | Where-Object -FilterScript { $_ -notin $Domains }

            if ($domainsToBeExcluded)
            {
                $PSBoundParameters.Add('DomainsToExclude', $domainsToBeExcluded) | Out-Null
            }
        }
    }

    # Removes only the passed domains.
    if ($PSBoundParameters.ContainsKey('DomainsToExclude'))
    {
        foreach ($domain in $PSBoundParameters.DomainsToExclude)
        {
            if ($domain -in $CurrentValues.Domains)
            {
                Write-Verbose -Message "Removing domain '$domain'"
                Remove-OfficeWebAppsHost -Domain $domain | Out-Null
            }
        }
    }

    # Adds the passed domains. Already existing ones stay unchanged.
    if ($PSBoundParameters.ContainsKey('DomainsToInclude'))
    {
        foreach ($domain in $PSBoundParameters.DomainsToInclude)
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
        $Domains,

        [Parameter()]
        [System.String[]]
        $DomainsToInclude,

        [Parameter()]
        [System.String[]]
        $DomainsToExclude
    )

    Write-Verbose -Message "Testing Office Online Server Farm host allow list"

    Import-Module -Name 'OfficeWebApps' -ErrorAction 'Stop' -Verbose:$false

    Confirm-OosDscEnvironmentVariables

    Test-OfficeOnlineServerHostPSBoundParameters @PSBoundParameters

    $CurrentValues = Get-TargetResource -Domains $Domains -IsSingleInstance 'Yes'

    $CurrentValues.Remove('Verbose') | Out-Null
    $PSBoundParameters.Remove('Verbose') | Out-Null

    Write-Verbose -Message "Current Values: $(Convert-OosDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-OosDscHashtableToString -Hashtable $PSBoundParameters)"

    if ($PSBoundParameters.ContainsKey('Domains'))
    {
        return Test-OosDscParameterState -CurrentValues $CurrentValues -DesiredValues $PSBoundParameters -ValuesToCheck 'Domains'
    }

    if ($PSBoundParameters.ContainsKey('DomainsToInclude'))
    {
        foreach ($domain in $PSBoundParameters.DomainsToInclude)
        {
            if ($domain -notin $CurrentValues.Domains)
            {
                return $false
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('DomainsToExclude'))
    {
        foreach ($domain in $PSBoundParameters.DomainsToExclude)
        {
            if ($domain -in $CurrentValues.Domains)
            {
                return $false
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('DomainsToExclude'))
    {
        forEach ($domain in $PSBoundParameters.DomainsToExclude)
        {
            if ($domain -in $CurrentValues.Domains)
            {
                return $false
            }
        }
    }

    return $true
}

function Test-OfficeOnlineServerHostPSBoundParameters
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
        $Domains,

        [Parameter()]
        [System.String[]]
        $DomainsToInclude,

        [Parameter()]
        [System.String[]]
        $DomainsToExclude
    )

    if ($PSBoundParameters.ContainsKey('Domains') -and
    ($PSBoundParameters.ContainsKey('DomainsToInclude') -or $PSBoundParameters.ContainsKey('DomainsToExclude')))
    {
        throw "Cannot use the Domains parameter together with the DomainsToInclude or DomainsToExclude parameters"
    }

    if (($PSBoundParameters.ContainsKey('DomainsToInclude') -and $PSBoundParameters.ContainsKey('DomainsToExclude')))
    {
        if ($comparison = Compare-Object -ReferenceObject $DomainsToInclude -DifferenceObject $DomainsToExclude -IncludeEqual -ExcludeDifferent)
        {
            throw "DomainsToInclude and DomainsToExclude contains one or more identical values. Please resolve"
        }
    }
}

Export-ModuleMember -Function *-TargetResource
