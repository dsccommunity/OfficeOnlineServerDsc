function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $InternalURL
    )

    try
    {
        $officeWebAppsFarm = Get-OfficeWebAppsFarm -ErrorAction Stop
    }
    catch
    {
        Write-Verbose $_        
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

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [System.Boolean]
        $AllowCEIP,

        [System.Boolean]
        $AllowHttp,

        [System.Boolean]
        $AllowHttpSecureStoreConnections,

        [System.String]
        $CacheLocation,

        [System.Int32]
        $CacheSizeInGB,

        [System.String]
        $CertificateName,

        [System.Boolean]
        $ClipartEnabled,

        [System.Int32]
        $DocumentInfoCacheSize,

        [System.Boolean]
        $EditingEnabled,

        [System.Boolean]
        $ExcelAllowExternalData,

        [System.Int32]
        $ExcelConnectionLifetime,

        [System.Int32]
        $ExcelExternalDataCacheLifetime,

        [System.Int32]
        $ExcelPrivateBytesMax,

        [System.Int32]
        $ExcelRequestDurationMax,

        [System.Int32]
        $ExcelSessionTimeout,

        [System.Boolean]
        $ExcelUdfsAllowed,

        [System.Boolean]
        $ExcelWarnOnDataRefresh,

        [System.Int32]
        $ExcelWorkbookSizeMax,

        [System.Int32]
        $ExcelMemoryCacheThreshold,

        [System.Int32]
        $ExcelUnusedObjectAgeMax,

        [System.Boolean]
        $ExcelCachingUnusedFiles,

        [System.Boolean]
        $ExcelAbortOnRefreshOnOpenFail,

        [System.Int32]
        $ExcelAutomaticVolatileFunctionCacheLifetime,

        [System.Int32]
        $ExcelConcurrentDataRequestsPerSessionMax,

        [System.String]
        $ExcelDefaultWorkbookCalcMode,

        [System.Boolean]
        $ExcelRestExternalDataEnabled,

        [System.Int32]
        $ExcelChartAndImageSizeMax,

        [System.String]
        $ExternalURL,

        [System.String]
        $FarmOU,

        [parameter(Mandatory = $true)]
        [System.String]
        $InternalURL,

        [System.String]
        $LogLocation,

        [System.Int32]
        $LogRetentionInDays,

        [System.String]
        $LogVerbosity,

        [System.Int32]
        $MaxMemoryCacheSizeInMB,

        [System.Int32]
        $MaxTranslationCharacterCount,

        [System.Boolean]
        $OpenFromUncEnabled,

        [System.Boolean]
        $OpenFromUrlEnabled,

        [System.Boolean]
        $OpenFromUrlThrottlingEnabled,

        [System.String]
        $Proxy,

        [System.Int32]
        $RecycleActiveProcessCount,

        [System.String]
        $RenderingLocalCacheLocation,

        [System.Boolean]
        $SSLOffloaded,

        [System.Boolean]
        $TranslationEnabled,

        [System.String]
        $TranslationServiceAddress,

        [System.String]
        $TranslationServiceAppId,

        [System.Boolean]
        $AllowOutboundHttp,

        [System.Boolean]
        $ExcelUseEffectiveUserName,

        [System.String]
        $S2SCertificateName,

        [System.Boolean]
        $RemovePersonalInformationFromLogs,

        [System.Boolean]
        $PicturePasteDisabled
    )

    $PSBoundParameters.Add('Force',$true)

    try
    {
        $officeWebAppsFarm = Get-OfficeWebAppsFarm -ErrorAction Stop
    }
    catch
    {
        Write-Verbose $_        
    }

    if(-not $officeWebAppsFarm)
    {
        Write-Verbose "Installing new WebAppsFarm"
        New-OfficeWebAppsFarm @PSBoundParameters
    }
    Else
    {
        Write-Verbose "WebAppsFarm found setting parameters on farm"
        Set-OfficeWebAppsFarm @PSBoundParameters
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [System.Boolean]
        $AllowCEIP,

        [System.Boolean]
        $AllowHttp,

        [System.Boolean]
        $AllowHttpSecureStoreConnections,

        [System.String]
        $CacheLocation,

        [System.Int32]
        $CacheSizeInGB,

        [System.String]
        $CertificateName,

        [System.Boolean]
        $ClipartEnabled,

        [System.Int32]
        $DocumentInfoCacheSize,

        [System.Boolean]
        $EditingEnabled,

        [System.Boolean]
        $ExcelAllowExternalData,

        [System.Int32]
        $ExcelConnectionLifetime,

        [System.Int32]
        $ExcelExternalDataCacheLifetime,

        [System.Int32]
        $ExcelPrivateBytesMax,

        [System.Int32]
        $ExcelRequestDurationMax,

        [System.Int32]
        $ExcelSessionTimeout,

        [System.Boolean]
        $ExcelUdfsAllowed,

        [System.Boolean]
        $ExcelWarnOnDataRefresh,

        [System.Int32]
        $ExcelWorkbookSizeMax,

        [System.Int32]
        $ExcelMemoryCacheThreshold,

        [System.Int32]
        $ExcelUnusedObjectAgeMax,

        [System.Boolean]
        $ExcelCachingUnusedFiles,

        [System.Boolean]
        $ExcelAbortOnRefreshOnOpenFail,

        [System.Int32]
        $ExcelAutomaticVolatileFunctionCacheLifetime,

        [System.Int32]
        $ExcelConcurrentDataRequestsPerSessionMax,

        [System.String]
        $ExcelDefaultWorkbookCalcMode,

        [System.Boolean]
        $ExcelRestExternalDataEnabled,

        [System.Int32]
        $ExcelChartAndImageSizeMax,

        [System.String]
        $ExternalURL,

        [System.String]
        $FarmOU,

        [parameter(Mandatory = $true)]
        [System.String]
        $InternalURL,

        [System.String]
        $LogLocation,

        [System.Int32]
        $LogRetentionInDays,

        [System.String]
        $LogVerbosity,

        [System.Int32]
        $MaxMemoryCacheSizeInMB,

        [System.Int32]
        $MaxTranslationCharacterCount,

        [System.Boolean]
        $OpenFromUncEnabled,

        [System.Boolean]
        $OpenFromUrlEnabled,

        [System.Boolean]
        $OpenFromUrlThrottlingEnabled,

        [System.String]
        $Proxy,

        [System.Int32]
        $RecycleActiveProcessCount,

        [System.String]
        $RenderingLocalCacheLocation,

        [System.Boolean]
        $SSLOffloaded,

        [System.Boolean]
        $TranslationEnabled,

        [System.String]
        $TranslationServiceAddress,

        [System.String]
        $TranslationServiceAppId,

        [System.Boolean]
        $AllowOutboundHttp,

        [System.Boolean]
        $ExcelUseEffectiveUserName,

        [System.String]
        $S2SCertificateName,

        [System.Boolean]
        $RemovePersonalInformationFromLogs,

        [System.Boolean]
        $PicturePasteDisabled
    )

    try
    {
        $officeWebAppsFarm = Get-OfficeWebAppsFarm -ErrorAction Stop
    }
    catch
    {
        Write-Verbose $_
        return $false
    }

    If($PSBoundParameters.ContainsKey('FarmOU') -and  ((Compare-FarmOu -FarmObj $officeWebAppsFarm -OuName $FarmOU) -ne $true))
    {
        Write-Verbose "FarmOU not in a desired state. Expected: $($PSBoundParameters['FarmOU']) Actual: $($officeWebAppsFarm.FarmOU)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('InternalURL'))
    {
        $vettedInternalUrl = Add-TrailingSlash -Uri $PSBoundParameters.InternalURL
                       
        If($vettedInternalUrl -ne $officeWebAppsFarm.InternalURL.AbsoluteUri)
        {
            Write-Verbose "InternalURL not in a desired state. Expected: $vettedInternalUrl Actual: $($officeWebAppsFarm.InternalURL.AbsoluteUri)"
            return $false
        }
    }

    If($PSBoundParameters.ContainsKey('ExternalURL'))
    {     
        $vettedExternalURL = Add-TrailingSlash -Uri $PSBoundParameters.ExternalURL

        If($vettedExternalURL -ne $officeWebAppsFarm.ExternalURL.AbsoluteUri)
        {
            Write-Verbose "ExternalURL not in a desired state. Expected: $vettedExternalURL Actual: $($officeWebAppsFarm.ExternalURL.AbsoluteUri)"
            return $false
        }
    }

    If($PSBoundParameters.ContainsKey('Proxy'))
    { 
        $vettedProxy = Add-TrailingSlash -Uri $PSBoundParameters.Proxy

        If($vettedProxy -ne $officeWebAppsFarm.Proxy.AbsoluteUri)
        {
            Write-Verbose "Proxy not in a desired state. Expected: $vettedProxy Actual: $($officeWebAppsFarm.Proxy.AbsoluteUri)"
            return $false
        }
    }

    If($PSBoundParameters.ContainsKey('AllowHTTP') -and  $PSBoundParameters['AllowHTTP'] -ne $officeWebAppsFarm.AllowHTTP)
    {
        Write-Verbose "AllowHTTP not in a desired state. Expected: $($PSBoundParameters['AllowHTTP']) Actual: $($officeWebAppsFarm.AllowHTTP)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('AllowOutboundHttp') -and  $PSBoundParameters['AllowOutboundHttp'] -ne $officeWebAppsFarm.AllowOutboundHttp)
    {
        Write-Verbose "AllowOutboundHttp not in a desired state. Expected: $($PSBoundParameters['AllowOutboundHttp']) Actual: $($officeWebAppsFarm.AllowOutboundHttp)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('SSLOffloaded') -and  $PSBoundParameters['SSLOffloaded'] -ne $officeWebAppsFarm.SSLOffloaded)
    {
        Write-Verbose "SSLOffloaded not in a desired state. Expected: $($PSBoundParameters['SSLOffloaded']) Actual: $($officeWebAppsFarm.SSLOffloaded)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('CertificateName') -and  $PSBoundParameters['CertificateName'] -ne $officeWebAppsFarm.CertificateName)
    {
        Write-Verbose "CertificateName not in a desired state. Expected: $($PSBoundParameters['CertificateName']) Actual: $($officeWebAppsFarm.CertificateName)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('S2SCertificateName') -and  $PSBoundParameters['S2SCertificateName'] -ne $officeWebAppsFarm.S2SCertificateName)
    {
        Write-Verbose "S2SCertificateName not in a desired state. Expected: $($PSBoundParameters['S2SCertificateName']) Actual: $($officeWebAppsFarm.S2SCertificateName)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('EditingEnabled') -and  $PSBoundParameters['EditingEnabled'] -ne $officeWebAppsFarm.EditingEnabled)
    {
        Write-Verbose "EditingEnabled not in a desired state. Expected: $($PSBoundParameters['EditingEnabled']) Actual: $($officeWebAppsFarm.EditingEnabled)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('LogLocation') -and  $PSBoundParameters['LogLocation'] -ne $officeWebAppsFarm.LogLocation)
    {
        Write-Verbose "LogLocation not in a desired state. Expected: $($PSBoundParameters['LogLocation']) Actual: $($officeWebAppsFarm.LogLocation)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('LogRetentionInDays') -and  $PSBoundParameters['LogRetentionInDays'] -ne $officeWebAppsFarm.LogRetentionInDays)
    {
        Write-Verbose "LogRetentionInDays not in a desired state. Expected: $($PSBoundParameters['LogRetentionInDays']) Actual: $($officeWebAppsFarm.LogRetentionInDays)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('LogVerbosity') -and  $PSBoundParameters['LogVerbosity'] -ne $officeWebAppsFarm.LogVerbosity)
    {
        Write-Verbose "LogVerbosity not in a desired state. Expected: $($PSBoundParameters['LogVerbosity']) Actual: $($officeWebAppsFarm.LogVerbosity)"
        return $false
    }


    If($PSBoundParameters.ContainsKey('CacheLocation') -and  $PSBoundParameters['CacheLocation'] -ne $officeWebAppsFarm.CacheLocation)
    {
        Write-Verbose "CacheLocation not in a desired state. Expected: $($PSBoundParameters['CacheLocation']) Actual: $($officeWebAppsFarm.CacheLocation)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('MaxMemoryCacheSizeInMB') -and  $PSBoundParameters['MaxMemoryCacheSizeInMB'] -ne $officeWebAppsFarm.MaxMemoryCacheSizeInMB)
    {
        Write-Verbose "MaxMemoryCacheSizeInMB not in a desired state. Expected: $($PSBoundParameters['MaxMemoryCacheSizeInMB']) Actual: $($officeWebAppsFarm.MaxMemoryCacheSizeInMB)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('DocumentInfoCacheSize') -and  $PSBoundParameters['DocumentInfoCacheSize'] -ne $officeWebAppsFarm.DocumentInfoCacheSize)
    {
        Write-Verbose "DocumentInfoCacheSize not in a desired state. Expected: $($PSBoundParameters['DocumentInfoCacheSize']) Actual: $($officeWebAppsFarm.DocumentInfoCacheSize)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('CacheSizeInGB') -and  $PSBoundParameters['CacheSizeInGB'] -ne $officeWebAppsFarm.CacheSizeInGB)
    {
        Write-Verbose "CacheSizeInGB not in a desired state. Expected: $($PSBoundParameters['CacheSizeInGB']) Actual: $($officeWebAppsFarm.CacheSizeInGB)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ClipartEnabled') -and  $PSBoundParameters['ClipartEnabled'] -ne $officeWebAppsFarm.ClipartEnabled)
    {
        Write-Verbose "ClipartEnabled not in a desired state. Expected: $($PSBoundParameters['ClipartEnabled']) Actual: $($officeWebAppsFarm.ClipartEnabled)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('TranslationEnabled') -and  $PSBoundParameters['TranslationEnabled'] -ne $officeWebAppsFarm.TranslationEnabled)
    {
        Write-Verbose "TranslationEnabled not in a desired state. Expected: $($PSBoundParameters['TranslationEnabled']) Actual: $($officeWebAppsFarm.TranslationEnabled)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('MaxTranslationCharacterCount') -and  $PSBoundParameters['MaxTranslationCharacterCount'] -ne $officeWebAppsFarm.MaxTranslationCharacterCount)
    {
        Write-Verbose "MaxTranslationCharacterCount not in a desired state. Expected: $($PSBoundParameters['MaxTranslationCharacterCount']) Actual: $($officeWebAppsFarm.MaxTranslationCharacterCount)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('TranslationServiceAppId') -and  $PSBoundParameters['TranslationServiceAppId'] -ne $officeWebAppsFarm.TranslationServiceAppId)
    {
        Write-Verbose "TranslationServiceAppId not in a desired state. Expected: $($PSBoundParameters['TranslationServiceAppId']) Actual: $($officeWebAppsFarm.TranslationServiceAppId)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('TranslationServiceAddress') -and  $PSBoundParameters['TranslationServiceAddress'] -ne $officeWebAppsFarm.TranslationServiceAddress)
    {
        Write-Verbose "TranslationServiceAddress not in a desired state. Expected: $($PSBoundParameters['TranslationServiceAddress']) Actual: $($officeWebAppsFarm.TranslationServiceAddress)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('RenderingLocalCacheLocation') -and  $PSBoundParameters['RenderingLocalCacheLocation'] -ne $officeWebAppsFarm.RenderingLocalCacheLocation)
    {
        Write-Verbose "RenderingLocalCacheLocation not in a desired state. Expected: $($PSBoundParameters['RenderingLocalCacheLocation']) Actual: $($officeWebAppsFarm.RenderingLocalCacheLocation)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('RecycleActiveProcessCount') -and  $PSBoundParameters['RecycleActiveProcessCount'] -ne $officeWebAppsFarm.RecycleActiveProcessCount)
    {
        Write-Verbose "RecycleActiveProcessCount not in a desired state. Expected: $($PSBoundParameters['RecycleActiveProcessCount']) Actual: $($officeWebAppsFarm.RecycleActiveProcessCount)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('AllowCEIP') -and  $PSBoundParameters['AllowCEIP'] -ne $officeWebAppsFarm.AllowCEIP)
    {
        Write-Verbose "AllowCEIP not in a desired state. Expected: $($PSBoundParameters['AllowCEIP']) Actual: $($officeWebAppsFarm.AllowCEIP)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelRequestDurationMax') -and  $PSBoundParameters['ExcelRequestDurationMax'] -ne $officeWebAppsFarm.ExcelRequestDurationMax)
    {
        Write-Verbose "ExcelRequestDurationMax not in a desired state. Expected: $($PSBoundParameters['ExcelRequestDurationMax']) Actual: $($officeWebAppsFarm.ExcelRequestDurationMax)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelSessionTimeout') -and  $PSBoundParameters['ExcelSessionTimeout'] -ne $officeWebAppsFarm.ExcelSessionTimeout)
    {
        Write-Verbose "ExcelSessionTimeout not in a desired state. Expected: $($PSBoundParameters['ExcelSessionTimeout']) Actual: $($officeWebAppsFarm.ExcelSessionTimeout)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelWorkbookSizeMax') -and  $PSBoundParameters['ExcelWorkbookSizeMax'] -ne $officeWebAppsFarm.ExcelWorkbookSizeMax)
    {
        Write-Verbose "ExcelWorkbookSizeMax not in a desired state. Expected: $($PSBoundParameters['ExcelWorkbookSizeMax']) Actual: $($officeWebAppsFarm.ExcelWorkbookSizeMax)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelPrivateBytesMax') -and  $PSBoundParameters['ExcelPrivateBytesMax'] -ne $officeWebAppsFarm.ExcelPrivateBytesMax)
    {
        Write-Verbose "ExcelPrivateBytesMax not in a desired state. Expected: $($PSBoundParameters['ExcelPrivateBytesMax']) Actual: $($officeWebAppsFarm.ExcelPrivateBytesMax)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelConnectionLifetime') -and  $PSBoundParameters['ExcelConnectionLifetime'] -ne $officeWebAppsFarm.ExcelConnectionLifetime)
    {
        Write-Verbose "ExcelConnectionLifetime not in a desired state. Expected: $($PSBoundParameters['ExcelConnectionLifetime']) Actual: $($officeWebAppsFarm.ExcelConnectionLifetime)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelExternalDataCacheLifetime') -and  $PSBoundParameters['ExcelExternalDataCacheLifetime'] -ne $officeWebAppsFarm.ExcelExternalDataCacheLifetime)
    {
        Write-Verbose "ExcelExternalDataCacheLifetime not in a desired state. Expected: $($PSBoundParameters['ExcelExternalDataCacheLifetime']) Actual: $($officeWebAppsFarm.ExcelExternalDataCacheLifetime)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelAllowExternalData') -and  $PSBoundParameters['ExcelAllowExternalData'] -ne $officeWebAppsFarm.ExcelAllowExternalData)
    {
        Write-Verbose "ExcelAllowExternalData not in a desired state. Expected: $($PSBoundParameters['ExcelAllowExternalData']) Actual: $($officeWebAppsFarm.ExcelAllowExternalData)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelUseEffectiveUserName') -and  $PSBoundParameters['ExcelUseEffectiveUserName'] -ne $officeWebAppsFarm.ExcelUseEffectiveUserName)
    {
        Write-Verbose "ExcelUseEffectiveUserName not in a desired state. Expected: $($PSBoundParameters['ExcelUseEffectiveUserName']) Actual: $($officeWebAppsFarm.ExcelUseEffectiveUserName)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelWarnOnDataRefresh') -and  $PSBoundParameters['ExcelWarnOnDataRefresh'] -ne $officeWebAppsFarm.ExcelWarnOnDataRefresh)
    {
        Write-Verbose "ExcelWarnOnDataRefresh not in a desired state. Expected: $($PSBoundParameters['ExcelWarnOnDataRefresh']) Actual: $($officeWebAppsFarm.ExcelWarnOnDataRefresh)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelUdfsAllowed') -and  $PSBoundParameters['ExcelUdfsAllowed'] -ne $officeWebAppsFarm.ExcelUdfsAllowed)
    {
        Write-Verbose "ExcelUdfsAllowed not in a desired state. Expected: $($PSBoundParameters['ExcelUdfsAllowed']) Actual: $($officeWebAppsFarm.ExcelUdfsAllowed)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelMemoryCacheThreshold') -and  $PSBoundParameters['ExcelMemoryCacheThreshold'] -ne $officeWebAppsFarm.ExcelMemoryCacheThreshold)
    {
        Write-Verbose "ExcelMemoryCacheThreshold not in a desired state. Expected: $($PSBoundParameters['ExcelMemoryCacheThreshold']) Actual: $($officeWebAppsFarm.ExcelMemoryCacheThreshold)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelUnusedObjectAgeMax') -and  $PSBoundParameters['ExcelUnusedObjectAgeMax'] -ne $officeWebAppsFarm.ExcelUnusedObjectAgeMax)
    {
        Write-Verbose "ExcelUnusedObjectAgeMax not in a desired state. Expected: $($PSBoundParameters['ExcelUnusedObjectAgeMax']) Actual: $($officeWebAppsFarm.ExcelUnusedObjectAgeMax)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelCachingUnusedFiles') -and  $PSBoundParameters['ExcelCachingUnusedFiles'] -ne $officeWebAppsFarm.ExcelCachingUnusedFiles)
    {
        Write-Verbose "ExcelCachingUnusedFiles not in a desired state. Expected: $($PSBoundParameters['ExcelCachingUnusedFiles']) Actual: $($officeWebAppsFarm.ExcelCachingUnusedFiles)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelAbortOnRefreshOnOpenFail') -and  $PSBoundParameters['ExcelAbortOnRefreshOnOpenFail'] -ne $officeWebAppsFarm.ExcelAbortOnRefreshOnOpenFail)
    {
        Write-Verbose "ExcelAbortOnRefreshOnOpenFail not in a desired state. Expected: $($PSBoundParameters['ExcelAbortOnRefreshOnOpenFail']) Actual: $($officeWebAppsFarm.ExcelAbortOnRefreshOnOpenFail)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelAutomaticVolatileFunctionCacheLifeTime') -and  $PSBoundParameters['ExcelAutomaticVolatileFunctionCacheLifeTime'] -ne $officeWebAppsFarm.ExcelAutomaticVolatileFunctionCacheLifeTime)
    {
        Write-Verbose "ExcelAutomaticVolatileFunctionCacheLifeTime not in a desired state. Expected: $($PSBoundParameters['ExcelAutomaticVolatileFunctionCacheLifeTime']) Actual: $($officeWebAppsFarm.ExcelAutomaticVolatileFunctionCacheLifeTime)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelConcurrentDataRequestsPerSessionMax') -and  $PSBoundParameters['ExcelConcurrentDataRequestsPerSessionMax'] -ne $officeWebAppsFarm.ExcelConcurrentDataRequestsPerSessionMax)
    {
        Write-Verbose "ExcelConcurrentDataRequestsPerSessionMax not in a desired state. Expected: $($PSBoundParameters['ExcelConcurrentDataRequestsPerSessionMax']) Actual: $($officeWebAppsFarm.ExcelConcurrentDataRequestsPerSessionMax)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelDefaultWorkbookCalcMode') -and  $PSBoundParameters['ExcelDefaultWorkbookCalcMode'] -ne $officeWebAppsFarm.ExcelDefaultWorkbookCalcMode)
    {
        Write-Verbose "ExcelDefaultWorkbookCalcMode not in a desired state. Expected: $($PSBoundParameters['ExcelDefaultWorkbookCalcMode']) Actual: $($officeWebAppsFarm.ExcelDefaultWorkbookCalcMode)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelRestExternalDataEnabled') -and  $PSBoundParameters['ExcelRestExternalDataEnabled'] -ne $officeWebAppsFarm.ExcelRestExternalDataEnabled)
    {
        Write-Verbose "ExcelRestExternalDataEnabled not in a desired state. Expected: $($PSBoundParameters['ExcelRestExternalDataEnabled']) Actual: $($officeWebAppsFarm.ExcelRestExternalDataEnabled)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('ExcelChartAndImageSizeMax') -and  $PSBoundParameters['ExcelChartAndImageSizeMax'] -ne $officeWebAppsFarm.ExcelChartAndImageSizeMax)
    {
        Write-Verbose "ExcelChartAndImageSizeMax not in a desired state. Expected: $($PSBoundParameters['ExcelChartAndImageSizeMax']) Actual: $($officeWebAppsFarm.ExcelChartAndImageSizeMax)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('OpenFromUrlEnabled') -and  $PSBoundParameters['OpenFromUrlEnabled'] -ne $officeWebAppsFarm.OpenFromUrlEnabled)
    {
        Write-Verbose "OpenFromUrlEnabled not in a desired state. Expected: $($PSBoundParameters['OpenFromUrlEnabled']) Actual: $($officeWebAppsFarm.OpenFromUrlEnabled)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('OpenFromUncEnabled') -and  $PSBoundParameters['OpenFromUncEnabled'] -ne $officeWebAppsFarm.OpenFromUncEnabled)
    {
        Write-Verbose "OpenFromUncEnabled not in a desired state. Expected: $($PSBoundParameters['OpenFromUncEnabled']) Actual: $($officeWebAppsFarm.OpenFromUncEnabled)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('OpenFromUrlThrottlingEnabled') -and  $PSBoundParameters['OpenFromUrlThrottlingEnabled'] -ne $officeWebAppsFarm.OpenFromUrlThrottlingEnabled)
    {
        Write-Verbose "OpenFromUrlThrottlingEnabled not in a desired state. Expected: $($PSBoundParameters['OpenFromUrlThrottlingEnabled']) Actual: $($officeWebAppsFarm.OpenFromUrlThrottlingEnabled)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('PicturePasteDisabled') -and  $PSBoundParameters['PicturePasteDisabled'] -ne $officeWebAppsFarm.PicturePasteDisabled)
    {
        Write-Verbose "PicturePasteDisabled not in a desired state. Expected: $($PSBoundParameters['PicturePasteDisabled']) Actual: $($officeWebAppsFarm.PicturePasteDisabled)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('RemovePersonalInformationFromLogs') -and  $PSBoundParameters['RemovePersonalInformationFromLogs'] -ne $officeWebAppsFarm.RemovePersonalInformationFromLogs)
    {
        Write-Verbose "RemovePersonalInformationFromLogs not in a desired state. Expected: $($PSBoundParameters['RemovePersonalInformationFromLogs']) Actual: $($officeWebAppsFarm.RemovePersonalInformationFromLogs)"
        return $false
    }

    If($PSBoundParameters.ContainsKey('AllowHttpSecureStoreConnections') -and  $PSBoundParameters['AllowHttpSecureStoreConnections'] -ne $officeWebAppsFarm.AllowHttpSecureStoreConnections)
    {
        Write-Verbose "AllowHttpSecureStoreConnections not in a desired state. Expected: $($PSBoundParameters['AllowHttpSecureStoreConnections']) Actual: $($officeWebAppsFarm.AllowHttpSecureStoreConnections)"
        return $false
    }

    #if the code made it this far all conditions must be true
    return $true
}


Export-ModuleMember -Function *-TargetResource

