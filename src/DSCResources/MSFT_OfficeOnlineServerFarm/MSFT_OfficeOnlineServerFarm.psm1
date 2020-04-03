$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'OfficeOnlineServerDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'OfficeOnlineServerDsc.Util.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_OfficeOnlineServerFarm'

$script:OOSDscRegKey = "HKLM:\SOFTWARE\OOSDsc"

$script:v16onlyParams = @("AllowOutboundHttp", "S2SCertificateName", "OnlinePictureEnabled", `
                          "OnlineVideoEnabled", "OfficeAddinEnabled", `
                          "ExcelUseEffectiveUserName", "ExcelUdfsAllowed", `
                          "ExcelMemoryCacheThreshold", "ExcelUnusedObjectAgeMax", `
                          "ExcelCachingUnusedFiles", "ExcelAbortOnRefreshOnOpenFail", `
                          "ExcelAutomaticVolatileFunctionCacheLifeTime", `
                          "ExcelConcurrentDataRequestsPerSessionMax", `
                          "ExcelDefaultWorkbookCalcMode", "ExcelRestExternalDataEnabled", `
                          "ExcelChartAndImageSizeMax")

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.Boolean]
        $AllowCEIP,

        [Parameter()]
        [System.Boolean]
        $AllowHttp,

        [Parameter()]
        [System.Boolean]
        $AllowHttpSecureStoreConnections,

        [Parameter()]
        [System.String]
        $CacheLocation,

        [Parameter()]
        [System.Int32]
        $CacheSizeInGB,

        [Parameter()]
        [System.String]
        $CertificateName,

        [Parameter()]
        [System.Boolean]
        $ClipartEnabled,

        [Parameter()]
        [System.Int32]
        $DocumentInfoCacheSize,

        [Parameter()]
        [System.Boolean]
        $EditingEnabled,

        [Parameter()]
        [System.Boolean]
        $ExcelAllowExternalData,

        [Parameter()]
        [System.Int32]
        $ExcelConnectionLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelExternalDataCacheLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelPrivateBytesMax,

        [Parameter()]
        [System.Int32]
        $ExcelRequestDurationMax,

        [Parameter()]
        [System.Int32]
        $ExcelSessionTimeout,

        [Parameter()]
        [System.Boolean]
        $ExcelUdfsAllowed,

        [Parameter()]
        [System.Boolean]
        $ExcelWarnOnDataRefresh,

        [Parameter()]
        [System.Int32]
        $ExcelWorkbookSizeMax,

        [Parameter()]
        [System.Int32]
        $ExcelMemoryCacheThreshold,

        [Parameter()]
        [System.Int32]
        $ExcelUnusedObjectAgeMax,

        [Parameter()]
        [System.Boolean]
        $ExcelCachingUnusedFiles,

        [Parameter()]
        [System.Boolean]
        $ExcelAbortOnRefreshOnOpenFail,

        [Parameter()]
        [System.Int32]
        $ExcelAutomaticVolatileFunctionCacheLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelConcurrentDataRequestsPerSessionMax,

        [Parameter()]
        [System.String]
        $ExcelDefaultWorkbookCalcMode,

        [Parameter()]
        [System.Boolean]
        $ExcelRestExternalDataEnabled,

        [Parameter()]
        [System.Int32]
        $ExcelChartAndImageSizeMax,

        [Parameter()]
        [System.String]
        $ExternalURL,

        [Parameter()]
        [System.String]
        $FarmOU,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InternalURL,

        [Parameter()]
        [System.String]
        $LogLocation,

        [Parameter()]
        [System.Int32]
        $LogRetentionInDays,

        [Parameter()]
        [System.String]
        $LogVerbosity,

        [Parameter()]
        [System.Int32]
        $MaxMemoryCacheSizeInMB,

        [Parameter()]
        [System.Int32]
        $MaxTranslationCharacterCount,

        [Parameter()]
        [System.Boolean]
        $OpenFromUncEnabled,

        [Parameter()]
        [System.Boolean]
        $OpenFromUrlEnabled,

        [Parameter()]
        [System.Boolean]
        $OpenFromUrlThrottlingEnabled,

        [Parameter()]
        [System.String]
        $Proxy,

        [Parameter()]
        [System.Int32]
        $RecycleActiveProcessCount,

        [Parameter()]
        [System.String]
        $RenderingLocalCacheLocation,

        [Parameter()]
        [System.Boolean]
        $SSLOffloaded,

        [Parameter()]
        [System.Boolean]
        $TranslationEnabled,

        [Parameter()]
        [System.String]
        $TranslationServiceAddress,

        [Parameter()]
        [System.String]
        $TranslationServiceAppId,

        [Parameter()]
        [System.Boolean]
        $AllowOutboundHttp,

        [Parameter()]
        [System.Boolean]
        $ExcelUseEffectiveUserName,

        [Parameter()]
        [System.String]
        $S2SCertificateName,

        [Parameter()]
        [System.Boolean]
        $RemovePersonalInformationFromLogs,

        [Parameter()]
        [System.Boolean]
        $PicturePasteDisabled
    )

    Write-Verbose -Message "Getting settings for local Office Online Server"

    Confirm-OosDscEnvironmentVariables

    Test-OosDscV16Support -Parameters $PSBoundParameters

    try
    {
        $officeWebAppsFarm = Get-OfficeWebAppsFarm -ErrorAction Stop
    }
    catch
    {
        Write-Verbose -Message $_
    }

    $returnValue = @{
        AllowCEIP = $officeWebAppsFarm.AllowCEIP
        AllowHttp = $officeWebAppsFarm.AllowHTTP
        AllowHttpSecureStoreConnections = $officeWebAppsFarm.AllowHttpSecureStoreConnections
        CacheLocation = $officeWebAppsFarm.CacheLocation
        CacheSizeInGB = $officeWebAppsFarm.CacheSizeInGB
        CertificateName = $officeWebAppsFarm.CertificateName
        ClipartEnabled = $officeWebAppsFarm.ClipartEnabled
        DocumentInfoCacheSize = $officeWebAppsFarm.DocumentInfoCacheSize
        EditingEnabled = $officeWebAppsFarm.EditingEnabled
        ExcelAllowExternalData = $officeWebAppsFarm.ExcelAllowExternalData
        ExcelConnectionLifetime = $officeWebAppsFarm.ExcelConnectionLifetime
        ExcelExternalDataCacheLifetime = $officeWebAppsFarm.ExcelExternalDataCacheLifetime
        ExcelPrivateBytesMax = $officeWebAppsFarm.ExcelPrivateBytesMax
        ExcelRequestDurationMax = $officeWebAppsFarm.ExcelRequestDurationMax
        ExcelSessionTimeout = $officeWebAppsFarm.ExcelSessionTimeout
        ExcelUdfsAllowed = $officeWebAppsFarm.ExcelUdfsAllowed
        ExcelWarnOnDataRefresh = $officeWebAppsFarm.ExcelWarnOnDataRefresh
        ExcelWorkbookSizeMax = $officeWebAppsFarm.ExcelWorkbookSizeMax
        ExcelMemoryCacheThreshold = $officeWebAppsFarm.ExcelMemoryCacheThreshold
        ExcelUnusedObjectAgeMax = $officeWebAppsFarm.ExcelUnusedObjectAgeMax
        ExcelCachingUnusedFiles = $officeWebAppsFarm.ExcelCachingUnusedFiles
        ExcelAbortOnRefreshOnOpenFail = $officeWebAppsFarm.ExcelAbortOnRefreshOnOpenFail
        ExcelAutomaticVolatileFunctionCacheLifetime = $officeWebAppsFarm.ExcelAutomaticVolatileFunctionCacheLifeTime
        ExcelConcurrentDataRequestsPerSessionMax = $officeWebAppsFarm.ExcelConcurrentDataRequestsPerSessionMax
        ExcelDefaultWorkbookCalcMode = $officeWebAppsFarm.ExcelDefaultWorkbookCalcMode
        ExcelRestExternalDataEnabled = $officeWebAppsFarm.ExcelRestExternalDataEnabled
        ExcelChartAndImageSizeMax = $officeWebAppsFarm.ExcelChartAndImageSizeMax
        ExternalURL = $officeWebAppsFarm.ExternalURL
        FarmOU = $officeWebAppsFarm.FarmOU
        InternalURL = $officeWebAppsFarm.InternalURL
        LogLocation = $officeWebAppsFarm.LogLocation
        LogRetentionInDays = $officeWebAppsFarm.LogRetentionInDays
        LogVerbosity = $officeWebAppsFarm.LogVerbosity
        MaxMemoryCacheSizeInMB = $officeWebAppsFarm.MaxMemoryCacheSizeInMB
        MaxTranslationCharacterCount = $officeWebAppsFarm.MaxTranslationCharacterCount
        OpenFromUncEnabled = $officeWebAppsFarm.OpenFromUncEnabled
        OpenFromUrlEnabled = $officeWebAppsFarm.OpenFromUrlEnabled
        OpenFromUrlThrottlingEnabled = $officeWebAppsFarm.OpenFromUrlThrottlingEnabled
        PicturePasteDisabled = $officeWebAppsFarm.PicturePasteDisabled
        Proxy = $officeWebAppsFarm.Proxy
        RecycleActiveProcessCount = $officeWebAppsFarm.RecycleActiveProcessCount
        RenderingLocalCacheLocation = $officeWebAppsFarm.RenderingLocalCacheLocation
        SSLOffloaded = $officeWebAppsFarm.SSLOffloaded
        TranslationEnabled = $officeWebAppsFarm.TranslationEnabled
        TranslationServiceAddress = $officeWebAppsFarm.TranslationServiceAddress
        TranslationServiceAppId = $officeWebAppsFarm.TranslationServiceAppId
        RemovePersonalInformationFromLogs = $officeWebAppsFarm.RemovePersonalInformationFromLogs
        ExcelUseEffectiveUserName = $officeWebAppsFarm.ExcelUseEffectiveUserName
        AllowOutboundHttp = $officeWebAppsFarm.AllowOutboundHttp
        S2SCertificateName = $officeWebAppsFarm.S2SCertificateName
    }

    return $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Boolean]
        $AllowCEIP,

        [Parameter()]
        [System.Boolean]
        $AllowHttp,

        [Parameter()]
        [System.Boolean]
        $AllowHttpSecureStoreConnections,

        [Parameter()]
        [System.String]
        $CacheLocation,

        [Parameter()]
        [System.Int32]
        $CacheSizeInGB,

        [Parameter()]
        [System.String]
        $CertificateName,

        [Parameter()]
        [System.Boolean]
        $ClipartEnabled,

        [Parameter()]
        [System.Int32]
        $DocumentInfoCacheSize,

        [Parameter()]
        [System.Boolean]
        $EditingEnabled,

        [Parameter()]
        [System.Boolean]
        $ExcelAllowExternalData,

        [Parameter()]
        [System.Int32]
        $ExcelConnectionLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelExternalDataCacheLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelPrivateBytesMax,

        [Parameter()]
        [System.Int32]
        $ExcelRequestDurationMax,

        [Parameter()]
        [System.Int32]
        $ExcelSessionTimeout,

        [Parameter()]
        [System.Boolean]
        $ExcelUdfsAllowed,

        [Parameter()]
        [System.Boolean]
        $ExcelWarnOnDataRefresh,

        [Parameter()]
        [System.Int32]
        $ExcelWorkbookSizeMax,

        [Parameter()]
        [System.Int32]
        $ExcelMemoryCacheThreshold,

        [Parameter()]
        [System.Int32]
        $ExcelUnusedObjectAgeMax,

        [Parameter()]
        [System.Boolean]
        $ExcelCachingUnusedFiles,

        [Parameter()]
        [System.Boolean]
        $ExcelAbortOnRefreshOnOpenFail,

        [Parameter()]
        [System.Int32]
        $ExcelAutomaticVolatileFunctionCacheLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelConcurrentDataRequestsPerSessionMax,

        [Parameter()]
        [System.String]
        $ExcelDefaultWorkbookCalcMode,

        [Parameter()]
        [System.Boolean]
        $ExcelRestExternalDataEnabled,

        [Parameter()]
        [System.Int32]
        $ExcelChartAndImageSizeMax,

        [Parameter()]
        [System.String]
        $ExternalURL,

        [Parameter()]
        [System.String]
        $FarmOU,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InternalURL,

        [Parameter()]
        [System.String]
        $LogLocation,

        [Parameter()]
        [System.Int32]
        $LogRetentionInDays,

        [Parameter()]
        [System.String]
        $LogVerbosity,

        [Parameter()]
        [System.Int32]
        $MaxMemoryCacheSizeInMB,

        [Parameter()]
        [System.Int32]
        $MaxTranslationCharacterCount,

        [Parameter()]
        [System.Boolean]
        $OpenFromUncEnabled,

        [Parameter()]
        [System.Boolean]
        $OpenFromUrlEnabled,

        [Parameter()]
        [System.Boolean]
        $OpenFromUrlThrottlingEnabled,

        [Parameter()]
        [System.String]
        $Proxy,

        [Parameter()]
        [System.Int32]
        $RecycleActiveProcessCount,

        [Parameter()]
        [System.String]
        $RenderingLocalCacheLocation,

        [Parameter()]
        [System.Boolean]
        $SSLOffloaded,

        [Parameter()]
        [System.Boolean]
        $TranslationEnabled,

        [Parameter()]
        [System.String]
        $TranslationServiceAddress,

        [Parameter()]
        [System.String]
        $TranslationServiceAppId,

        [Parameter()]
        [System.Boolean]
        $AllowOutboundHttp,

        [Parameter()]
        [System.Boolean]
        $ExcelUseEffectiveUserName,

        [Parameter()]
        [System.String]
        $S2SCertificateName,

        [Parameter()]
        [System.Boolean]
        $RemovePersonalInformationFromLogs,

        [Parameter()]
        [System.Boolean]
        $PicturePasteDisabled
    )

    Write-Verbose -Message "Updating settings for local Office Online Server"

    Confirm-OosDscEnvironmentVariables

    Test-OosDscV16Support -Parameters $PSBoundParameters

    try
    {
        $officeWebAppsFarm = Get-OfficeWebAppsFarm -ErrorAction Stop
    }
    catch
    {
        Write-Verbose -Message $_
    }

    if (-not $officeWebAppsFarm)
    {
        Write-Verbose -Message $script:localizedData.InstallingNewFarm
        $null = New-OfficeWebAppsFarm @PSBoundParameters -Force
    }
    else
    {
        Write-Verbose -Message $script:localizedData.FarmExists
        $null = Set-OfficeWebAppsFarm @PSBoundParameters -Force
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.Boolean]
        $AllowCEIP,

        [Parameter()]
        [System.Boolean]
        $AllowHttp,

        [Parameter()]
        [System.Boolean]
        $AllowHttpSecureStoreConnections,

        [Parameter()]
        [System.String]
        $CacheLocation,

        [Parameter()]
        [System.Int32]
        $CacheSizeInGB,

        [Parameter()]
        [System.String]
        $CertificateName,

        [Parameter()]
        [System.Boolean]
        $ClipartEnabled,

        [Parameter()]
        [System.Int32]
        $DocumentInfoCacheSize,

        [Parameter()]
        [System.Boolean]
        $EditingEnabled,

        [Parameter()]
        [System.Boolean]
        $ExcelAllowExternalData,

        [Parameter()]
        [System.Int32]
        $ExcelConnectionLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelExternalDataCacheLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelPrivateBytesMax,

        [Parameter()]
        [System.Int32]
        $ExcelRequestDurationMax,

        [Parameter()]
        [System.Int32]
        $ExcelSessionTimeout,

        [Parameter()]
        [System.Boolean]
        $ExcelUdfsAllowed,

        [Parameter()]
        [System.Boolean]
        $ExcelWarnOnDataRefresh,

        [Parameter()]
        [System.Int32]
        $ExcelWorkbookSizeMax,

        [Parameter()]
        [System.Int32]
        $ExcelMemoryCacheThreshold,

        [Parameter()]
        [System.Int32]
        $ExcelUnusedObjectAgeMax,

        [Parameter()]
        [System.Boolean]
        $ExcelCachingUnusedFiles,

        [Parameter()]
        [System.Boolean]
        $ExcelAbortOnRefreshOnOpenFail,

        [Parameter()]
        [System.Int32]
        $ExcelAutomaticVolatileFunctionCacheLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelConcurrentDataRequestsPerSessionMax,

        [Parameter()]
        [System.String]
        $ExcelDefaultWorkbookCalcMode,

        [Parameter()]
        [System.Boolean]
        $ExcelRestExternalDataEnabled,

        [Parameter()]
        [System.Int32]
        $ExcelChartAndImageSizeMax,

        [Parameter()]
        [System.String]
        $ExternalURL,

        [Parameter()]
        [System.String]
        $FarmOU,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InternalURL,

        [Parameter()]
        [System.String]
        $LogLocation,

        [Parameter()]
        [System.Int32]
        $LogRetentionInDays,

        [Parameter()]
        [System.String]
        $LogVerbosity,

        [Parameter()]
        [System.Int32]
        $MaxMemoryCacheSizeInMB,

        [Parameter()]
        [System.Int32]
        $MaxTranslationCharacterCount,

        [Parameter()]
        [System.Boolean]
        $OpenFromUncEnabled,

        [Parameter()]
        [System.Boolean]
        $OpenFromUrlEnabled,

        [Parameter()]
        [System.Boolean]
        $OpenFromUrlThrottlingEnabled,

        [Parameter()]
        [System.String]
        $Proxy,

        [Parameter()]
        [System.Int32]
        $RecycleActiveProcessCount,

        [Parameter()]
        [System.String]
        $RenderingLocalCacheLocation,

        [Parameter()]
        [System.Boolean]
        $SSLOffloaded,

        [Parameter()]
        [System.Boolean]
        $TranslationEnabled,

        [Parameter()]
        [System.String]
        $TranslationServiceAddress,

        [Parameter()]
        [System.String]
        $TranslationServiceAppId,

        [Parameter()]
        [System.Boolean]
        $AllowOutboundHttp,

        [Parameter()]
        [System.Boolean]
        $ExcelUseEffectiveUserName,

        [Parameter()]
        [System.String]
        $S2SCertificateName,

        [Parameter()]
        [System.Boolean]
        $RemovePersonalInformationFromLogs,

        [Parameter()]
        [System.Boolean]
        $PicturePasteDisabled
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
            Write-Verbose -Message $script:localizedData.ContinueAfterPatching
            return $true
        }
    }

    Test-OosDscV16Support -Parameters $PSBoundParameters

    try
    {
        $officeWebAppsFarm = Get-OfficeWebAppsFarm -ErrorAction Stop
    }
    catch
    {
        Write-Verbose -Message $_
        return $false
    }

    if ($PSBoundParameters.ContainsKey('FarmOU'))
    {
        if ((Test-OosDscFarmOu -ExistingOU $officeWebAppsFarm.FarmOU -DesiredOU $FarmOU) -ne $true)
        {
            Write-Verbose -Message ("FarmOU not in a desired state. " + `
                                    "Expected: '$($PSBoundParameters['FarmOU'])'. " + `
                                    "Actual: '$($officeWebAppsFarm.FarmOU)'.")
            return $false
        }
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-OosDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-OosDscHashtableToString -Hashtable $PSBoundParameters)"

    if ($InternalURL.EndsWith('/') -eq $false)
    {
        $InternalURL += "/"
    }
    if ($ExternalURL.EndsWith('/') -eq $false)
    {
        $ExternalURL += "/"
    }
    if ($Proxy.EndsWith('/') -eq $false)
    {
        $Proxy += "/"
    }
    return Test-OosDscParameterState -CurrentValues $CurrentValues `
                                   -DesiredValues $PSBoundParameters `
                                   -ValuesToCheck @(
                                       "InternalURL",
                                       "ExternalURL",
                                       "Proxy",
                                       "AllowHTTP",
                                       "AllowOutboundHttp",
                                       "SSLOffloaded",
                                       "CertificateName",
                                       "S2SCertificateName",
                                       "EditingEnabled",
                                       "LogLocation",
                                       "LogRetentionInDays",
                                       "LogVerbosity",
                                       "CacheLocation",
                                       "MaxMemoryCacheSizeInMB",
                                       "DocumentInfoCacheSize",
                                       "CacheSizeInGB",
                                       "ClipartEnabled",
                                       "TranslationEnabled",
                                       "MaxTranslationCharacterCount",
                                       "TranslationServiceAppId",
                                       "TranslationServiceAddress",
                                       "RenderingLocalCacheLocation",
                                       "RecycleActiveProcessCount",
                                       "AllowCEIP",
                                       "ExcelRequestDurationMax",
                                       "ExcelSessionTimeout",
                                       "ExcelWorkbookSizeMax",
                                       "ExcelPrivateBytesMax",
                                       "ExcelConnectionLifetime",
                                       "ExcelExternalDataCacheLifetime",
                                       "ExcelAllowExternalData",
                                       "ExcelUseEffectiveUserName",
                                       "ExcelWarnOnDataRefresh",
                                       "ExcelUdfsAllowed",
                                       "ExcelMemoryCacheThreshold",
                                       "ExcelUnusedObjectAgeMax",
                                       "ExcelCachingUnusedFiles",
                                       "ExcelAbortOnRefreshOnOpenFail",
                                       "ExcelAutomaticVolatileFunctionCacheLifeTime",
                                       "ExcelConcurrentDataRequestsPerSessionMax",
                                       "ExcelDefaultWorkbookCalcMode",
                                       "ExcelRestExternalDataEnabled",
                                       "ExcelChartAndImageSizeMax",
                                       "OpenFromUrlEnabled",
                                       "OpenFromUncEnabled",
                                       "OpenFromUrlThrottlingEnabled",
                                       "PicturePasteDisabled",
                                       "RemovePersonalInformationFromLogs",
                                       "AllowHttpSecureStoreConnections"
                                    )
}

function Test-OosDscV16Support
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory=$true)]
        [Object]
        $Parameters
    )

    $version = Get-OosDscInstalledProductVersion
    switch ($version.Major)
    {
        15 {
            Write-Verbose -Message $script:localizedData.OWA2013Detected
            foreach ($param in $script:v16onlyParams)
            {
                if ($Parameters.ContainsKey($param) -eq $true)
                {
                    throw "The parameter '$param' is not supported on Office Web Apps Server 2013"
                }
            }
        }
        16 {
            Write-Verbose -Message $script:localizedData.OOS2016Detected
        }
        Default {
            throw ("This module only supports Office Web Apps 2013 (v15) and Office " + `
                   "Online Server 2016 (v16). Detected version was $($version.Major)")
        }
    }
}

Export-ModuleMember -Function *-TargetResource

