$script:resourceHelperModulePath = @(
    (Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\OfficeOnlineServerDsc.Util'),
    (Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common')
)
Import-Module -Name $script:resourceHelperModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'
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
        $Domains,

        [Parameter()]
        [System.String[]]
        $DomainsToInclude,

        [Parameter()]
        [System.String[]]
        $DomainsToExclude
    )

    Write-Verbose -Message $script:localizedData.GetAllowList

    Import-Module -Name 'OfficeWebApps' -ErrorAction 'Stop' -Verbose:$false

    Confirm-OosDscEnvironmentVariables

    $currentValues = Remove-CommonParameter $PSBoundParameters

    Test-OfficeOnlineServerHostBoundParameter @currentValues

    try
    {
        $currentValues.Domains = [System.Array](Get-OfficeWebAppsHost -ErrorAction 'Stop').AllowList
    }
    catch
    {
        throw $_
    }

    return $currentValues
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

    Write-Verbose -Message $script:localizedData.UpdateAllowList

    $currentValues = Get-TargetResource -Domains $Domains -IsSingleInstance 'Yes'
    $targetValues = Remove-CommonParameter $PSBoundParameters

    if ($PSBoundParameters.ContainsKey('Domains'))
    {
        # Pass empty array, then all existing domains will be deleted
        if ($null -eq $Domains)
        {
            $targetValues.Add('DomainsToExclude', $currentValues.Domains) | Out-Null
        }
        # Compares current vs target domains and decided wich ones to keep
        else
        {
            $targetValues.Add('DomainsToInclude', $Domains) | Out-Null

            if ($domainsToBeExcluded = $currentValues.Domains | Where-Object -FilterScript { $_ -notin $Domains })
            {
                $targetValues.Add('DomainsToExclude', $domainsToBeExcluded) | Out-Null
            }
        }
    }

    # Removes only the passed domains.
    if ($targetValues.ContainsKey('DomainsToExclude'))
    {
        foreach ($domain in $targetValues.DomainsToExclude)
        {
            if ($domain -in $currentValues.Domains)
            {
                Write-Verbose -Message "$($script:localizedData.RemoveDomain) '$domain'"
                Remove-OfficeWebAppsHost -Domain $domain | Out-Null
            }
        }
    }

    # Adds the passed domains. Already existing ones stay unchanged.
    if ($targetValues.ContainsKey('DomainsToInclude'))
    {
        foreach ($domain in $targetValues.DomainsToInclude)
        {
            if ($domain -notin $currentValues.Domains)
            {
                Write-Verbose -Message "$($script:localizedData.AddDomain) '$domain'"
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

    Write-Verbose -Message $script:localizedData.TestAllowList

    $currentValues = Get-TargetResource @PSBoundParameters
    $targetValues = Remove-CommonParameter -Hashtable $PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-OosDscHashtableToString -Hashtable $currentValues)"
    Write-Verbose -Message "Target Values: $(Convert-OosDscHashtableToString -Hashtable $targetValues)"

    if ($targetValues.ContainsKey('Domains'))
    {
        return Test-DscParameterState -CurrentValues $currentValues -DesiredValues $targetValues -Properties 'Domains' -TurnOffTypeChecking
    }

    if ($targetValues.ContainsKey('DomainsToInclude'))
    {
        foreach ($domain in $targetValues.DomainsToInclude)
        {
            if ($domain -notin $currentValues.Domains)
            {
                return $false
            }
        }
    }

    if ($targetValues.ContainsKey('DomainsToExclude'))
    {
        foreach ($domain in $targetValues.DomainsToExclude)
        {
            if ($domain -in $currentValues.Domains)
            {
                return $false
            }
        }
    }

    return $true
}

<#
    .SYNOPSIS
        Validates the PSBoundParameters of OfficeOnlineServerHost

    .EXAMPLE
        Test-OfficeOnlineServerHostBoundParameter @PSBoundParameters
#>
function Test-OfficeOnlineServerHostBoundParameter
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

    Assert-BoundParameter -BoundParameterList $PSBoundParameters -MutuallyExclusiveList1 'Domains' -MutuallyExclusiveList2 'DomainsToInclude', 'DomainsToExclude'

    if (($PSBoundParameters.ContainsKey('DomainsToInclude') -and $PSBoundParameters.ContainsKey('DomainsToExclude')))
    {
        if (Compare-Object -ReferenceObject $DomainsToInclude -DifferenceObject $DomainsToExclude -IncludeEqual -ExcludeDifferent)
        {
            New-InvalidOperationException -Message $script:localizedData.DuplicateDomains
        }
    }
}

Export-ModuleMember -Function *-TargetResource
