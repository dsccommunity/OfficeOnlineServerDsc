function Get-OfficeWebAppsFarm
{
    [CmdletBinding()]
    Param()


}

function Get-OfficeWebAppsHost
{
    [CmdletBinding()]
    Param()


}

function Get-OfficeWebAppsMachine
{
    [CmdletBinding()]
    Param()


}

function New-OfficeWebAppsFarm
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param
    (
        [switch]
        ${Force},

        [string]
        ${FarmOU},

        [string]
        ${InternalURL},

        [string]
        ${ExternalURL},

        [switch]
        ${AllowHttp},

        [switch]
        ${SSLOffloaded},

        [string]
        ${CertificateName},

        [switch]
        ${EditingEnabled},

        [string]
        ${Proxy},

        [string]
        ${LogLocation},

        [System.Nullable[uint32]]
        ${LogRetentionInDays},

        [string]
        ${LogVerbosity},

        [string]
        ${CacheLocation},

        [System.Nullable[int]]
        ${MaxMemoryCacheSizeInMB},

        [System.Nullable[uint32]]
        ${DocumentInfoCacheSize},

        [System.Nullable[int]]
        ${CacheSizeInGB},

        [switch]
        ${ClipartEnabled},

        [switch]
        ${IgnoreDeserializationFilter},

        [switch]
        ${TranslationEnabled},

        [System.Nullable[int]]
        ${MaxTranslationCharacterCount},

        [string]
        ${TranslationServiceAppId},

        [string]
        ${TranslationServiceAddress},

        [string]
        ${RenderingLocalCacheLocation},

        [System.Nullable[uint32]]
        ${RecycleActiveProcessCount},

        [switch]
        ${AllowCEIP},

        [System.Nullable[int]]
        ${ExcelRequestDurationMax},

        [System.Nullable[int]]
        ${ExcelSessionTimeout},

        [System.Nullable[int]]
        ${ExcelWorkbookSizeMax},

        [System.Nullable[int]]
        ${ExcelPrivateBytesMax},

        [System.Nullable[int]]
        ${ExcelConnectionLifetime},

        [System.Nullable[int]]
        ${ExcelExternalDataCacheLifetime},

        [switch]
        ${ExcelAllowExternalData},

        [switch]
        ${ExcelWarnOnDataRefresh},

        [switch]
        ${OpenFromUrlEnabled},

        [switch]
        ${OpenFromUncEnabled},

        [switch]
        ${OpenFromUrlThrottlingEnabled},

        [switch]
        ${PicturePasteDisabled},

        [switch]
        ${RemovePersonalInformationFromLogs},

        [switch]
        ${AllowHttpSecureStoreConnections})


}

function New-OfficeWebAppsHost
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        ${Domain})


}

function New-OfficeWebAppsMachine
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param
    (
        [switch]
        ${Force},

        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${MachineToJoin},

        [string[]]
        ${Roles})


}

function Remove-OfficeWebAppsHost
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        ${Domain})


}

function Remove-OfficeWebAppsMachine
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param()


}

function Repair-OfficeWebAppsFarm
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param
    (
        [switch]
        ${Force})


}

function Set-OfficeWebAppsFarm
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param
    (
        [switch]
        ${Force},

        [string]
        ${FarmOU},

        [string]
        ${InternalURL},

        [string]
        ${ExternalURL},

        [switch]
        ${AllowHttp},

        [switch]
        ${SSLOffloaded},

        [string]
        ${CertificateName},

        [switch]
        ${EditingEnabled},

        [string]
        ${Proxy},

        [string]
        ${LogLocation},

        [System.Nullable[uint32]]
        ${LogRetentionInDays},

        [string]
        ${LogVerbosity},

        [string]
        ${CacheLocation},

        [System.Nullable[int]]
        ${MaxMemoryCacheSizeInMB},

        [System.Nullable[uint32]]
        ${DocumentInfoCacheSize},

        [System.Nullable[int]]
        ${CacheSizeInGB},

        [switch]
        ${ClipartEnabled},

        [switch]
        ${IgnoreDeserializationFilter},

        [switch]
        ${TranslationEnabled},

        [System.Nullable[int]]
        ${MaxTranslationCharacterCount},

        [string]
        ${TranslationServiceAppId},

        [string]
        ${TranslationServiceAddress},

        [string]
        ${RenderingLocalCacheLocation},

        [System.Nullable[uint32]]
        ${RecycleActiveProcessCount},

        [switch]
        ${AllowCEIP},

        [System.Nullable[int]]
        ${ExcelRequestDurationMax},

        [System.Nullable[int]]
        ${ExcelSessionTimeout},

        [System.Nullable[int]]
        ${ExcelWorkbookSizeMax},

        [System.Nullable[int]]
        ${ExcelPrivateBytesMax},

        [System.Nullable[int]]
        ${ExcelConnectionLifetime},

        [System.Nullable[int]]
        ${ExcelExternalDataCacheLifetime},

        [switch]
        ${ExcelAllowExternalData},

        [switch]
        ${ExcelWarnOnDataRefresh},

        [switch]
        ${OpenFromUrlEnabled},

        [switch]
        ${OpenFromUncEnabled},

        [switch]
        ${OpenFromUrlThrottlingEnabled},

        [switch]
        ${PicturePasteDisabled},

        [switch]
        ${RemovePersonalInformationFromLogs},

        [switch]
        ${AllowHttpSecureStoreConnections})


}

function Set-OfficeWebAppsMachine
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param
    (
        [string]
        ${Master},

        [string[]]
        ${Roles})


}


