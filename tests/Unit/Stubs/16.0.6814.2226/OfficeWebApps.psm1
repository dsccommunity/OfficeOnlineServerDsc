function Get-OfficeWebAppsExcelBIServer
{
    [CmdletBinding()]
    Param()


}

function Get-OfficeWebAppsExcelUserDefinedFunction
{
    [CmdletBinding()]
    Param
    (
        [Parameter(ParameterSetName = 'Identity', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Object]
        ${Identity})


}

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

function New-OfficeWebAppsExcelBIServer
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        ${ServerId})


}

function New-OfficeWebAppsExcelUserDefinedFunction
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        ${Assembly},

        [Object]
        ${AssemblyLocation},

        [string]
        ${Description},

        [switch]
        ${Enable})


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
        ${AllowOutboundHttp},

        [switch]
        ${SSLOffloaded},

        [string]
        ${CertificateName},

        [string]
        ${S2SCertificateName},

        [switch]
        ${EditingEnabled},

        [string]
        ${Proxy},

        [string]
        ${LogLocation},

        [uint32]
        ${LogRetentionInDays},

        [string]
        ${LogVerbosity},

        [string]
        ${CacheLocation},

        [int]
        ${MaxMemoryCacheSizeInMB},

        [uint32]
        ${DocumentInfoCacheSize},

        [int]
        ${CacheSizeInGB},

        [switch]
        ${ClipartEnabled},

        [switch]
        ${OnlinePictureEnabled},

        [switch]
        ${OnlineVideoEnabled},

        [switch]
        ${TranslationEnabled},

        [int]
        ${MaxTranslationCharacterCount},

        [string]
        ${TranslationServiceAppId},

        [string]
        ${TranslationServiceAddress},

        [string]
        ${RenderingLocalCacheLocation},

        [uint32]
        ${RecycleActiveProcessCount},

        [switch]
        ${AllowCEIP},

        [switch]
        ${OfficeAddinEnabled},

        [int]
        ${ExcelRequestDurationMax},

        [int]
        ${ExcelSessionTimeout},

        [int]
        ${ExcelWorkbookSizeMax},

        [int]
        ${ExcelPrivateBytesMax},

        [int]
        ${ExcelConnectionLifetime},

        [int]
        ${ExcelExternalDataCacheLifetime},

        [switch]
        ${ExcelAllowExternalData},

        [switch]
        ${ExcelUseEffectiveUserName},

        [switch]
        ${ExcelWarnOnDataRefresh},

        [switch]
        ${ExcelUdfsAllowed},

        [int]
        ${ExcelMemoryCacheThreshold},

        [int]
        ${ExcelUnusedObjectAgeMax},

        [switch]
        ${ExcelCachingUnusedFiles},

        [switch]
        ${ExcelAbortOnRefreshOnOpenFail},

        [int]
        ${ExcelAutomaticVolatileFunctionCacheLifeTime},

        [int]
        ${ExcelConcurrentDataRequestsPerSessionMax},

        [Object]
        ${ExcelDefaultWorkbookCalcMode},

        [switch]
        ${ExcelRestExternalDataEnabled},

        [int]
        ${ExcelChartAndImageSizeMax},

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

function Remove-OfficeWebAppsExcelBIServer
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        ${ServerId})


}

function Remove-OfficeWebAppsExcelUserDefinedFunction
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Object]
        ${Identity})


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

function Set-OfficeWebAppsExcelUserDefinedFunction
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Object]
        ${Identity},

        [string]
        ${Assembly},

        [Object]
        ${AssemblyLocation},

        [string]
        ${Description},

        [switch]
        ${Enable})


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
        ${AllowOutboundHttp},

        [switch]
        ${SSLOffloaded},

        [string]
        ${CertificateName},

        [string]
        ${S2SCertificateName},

        [switch]
        ${EditingEnabled},

        [string]
        ${Proxy},

        [string]
        ${LogLocation},

        [uint32]
        ${LogRetentionInDays},

        [string]
        ${LogVerbosity},

        [string]
        ${CacheLocation},

        [int]
        ${MaxMemoryCacheSizeInMB},

        [uint32]
        ${DocumentInfoCacheSize},

        [int]
        ${CacheSizeInGB},

        [switch]
        ${ClipartEnabled},

        [switch]
        ${OnlinePictureEnabled},

        [switch]
        ${OnlineVideoEnabled},

        [switch]
        ${TranslationEnabled},

        [int]
        ${MaxTranslationCharacterCount},

        [string]
        ${TranslationServiceAppId},

        [string]
        ${TranslationServiceAddress},

        [string]
        ${RenderingLocalCacheLocation},

        [uint32]
        ${RecycleActiveProcessCount},

        [switch]
        ${AllowCEIP},

        [switch]
        ${OfficeAddinEnabled},

        [int]
        ${ExcelRequestDurationMax},

        [int]
        ${ExcelSessionTimeout},

        [int]
        ${ExcelWorkbookSizeMax},

        [int]
        ${ExcelPrivateBytesMax},

        [int]
        ${ExcelConnectionLifetime},

        [int]
        ${ExcelExternalDataCacheLifetime},

        [switch]
        ${ExcelAllowExternalData},

        [switch]
        ${ExcelUseEffectiveUserName},

        [switch]
        ${ExcelWarnOnDataRefresh},

        [switch]
        ${ExcelUdfsAllowed},

        [int]
        ${ExcelMemoryCacheThreshold},

        [int]
        ${ExcelUnusedObjectAgeMax},

        [switch]
        ${ExcelCachingUnusedFiles},

        [switch]
        ${ExcelAbortOnRefreshOnOpenFail},

        [int]
        ${ExcelAutomaticVolatileFunctionCacheLifeTime},

        [int]
        ${ExcelConcurrentDataRequestsPerSessionMax},

        [Object]
        ${ExcelDefaultWorkbookCalcMode},

        [switch]
        ${ExcelRestExternalDataEnabled},

        [int]
        ${ExcelChartAndImageSizeMax},

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


