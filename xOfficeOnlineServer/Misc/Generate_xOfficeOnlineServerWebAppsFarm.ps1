$props = @()
$props += New-xDscResourceProperty -Name AllowCEIP -Type Boolean -Attribute Write -Description 'Enables Customer Experience Improvement Program (CEIP) reporting on all servers in the Office Web Apps Server farm'
$props += New-xDscResourceProperty -Name AllowHttp -Type Boolean -Attribute Write -Description 'Indicates that IIS sites should be provisioned on port 80 for HTTP access. Use AllowHTTP only in environments where all computers require IPSEC (full encryption) or in test environments that do not contain sensitive files.'
$props += New-xDscResourceProperty -Name AllowHttpSecureStoreConnections -Type Boolean -Attribute Write -Description 'Indicates that secure store connections can be made by using non-SSL connections (such as HTTP). The default is False.'
$props += New-xDscResourceProperty -Name CacheLocation -Type String -Attribute Write -Description 'Specifies the location of the global disk cache that is used to store rendered image files.'
$props += New-xDscResourceProperty -Name CacheSizeInGB -Type Sint32 -Attribute Write -Description 'Specifies the maximum size of the global disk cache in gigabytes.'
$props += New-xDscResourceProperty -Name CertificateName -Type String -Attribute Write -Description 'Specifies the friendly name of the certificate that Office Web Apps Server uses to create HTTPS bindings.'
$props += New-xDscResourceProperty -Name ClipartEnabled -Type Boolean -Attribute Write -Description 'Enables support for inserting clip art from Office.com into Office documents. This feature requires server-to-web communication, configured either directly or by using a proxy that you specify by using the Proxy parameter.'
$props += New-xDscResourceProperty -Name DocumentInfoCacheSize -Type Sint32 -Attribute Write -Description 'Specifies the maximum number of document conversion records that are stored in a memory cache.'
$props += New-xDscResourceProperty -Name EditingEnabled -Type Boolean -Attribute Write -Description 'Enables support for editing in the browser. The default is False. Only set to True if you have the appropriate licensing to use the editing functionality.'
$props += New-xDscResourceProperty -Name ExcelAllowExternalData -Type Boolean -Attribute Write -Description 'Enables the refresh of supported external data in Excel Web App workbooks where workbooks contain connections to external data. The default is True.'
$props += New-xDscResourceProperty -Name ExcelConnectionLifetime -Type Sint32 -Attribute Write -Description 'Specifies the duration, in seconds, of external data connections for Excel Web App. The default is 1800 seconds.'
$props += New-xDscResourceProperty -Name ExcelExternalDataCacheLifetime -Type Sint32 -Attribute Write -Description 'Specifes the duration, in seconds, of the external data cache lifetime in Excel Web App. The default is 300 seconds.'
$props += New-xDscResourceProperty -Name ExcelPrivateBytesMax -Type Sint32 -Attribute Write -Description 'Specifies the maximum private bytes, in megabytes, used by Excel Web App. When set to -1, the maximum private bytes use 50 percent of physical memory on the computer.'
$props += New-xDscResourceProperty -Name ExcelRequestDurationMax -Type Sint32 -Attribute Write -Description 'Specifies the maximum duration, in seconds, for a single request in a session. After this time elapses, the request times out.'
#Look online for valid values
$props += New-xDscResourceProperty -Name ExcelSessionTimeout -Type Sint32 -Attribute Write -Description 'Specifies the time, in seconds, that a session remains active in Excel Web App when there is no user activity.'
$props += New-xDscResourceProperty -Name ExcelUdfsAllowed -Type Boolean -Attribute Write -Description 'Activates user-defined functions for use with Web Excel.'
$props += New-xDscResourceProperty -Name ExcelWarnOnDataRefresh -Type Boolean -Attribute Write -Description 'Turns off or on the warning dialog displayed when data refreshes in Excel Web App.'
$props += New-xDscResourceProperty -Name ExcelWorkbookSizeMax -Type Sint32 -Attribute Write -Description 'Specifies the maximum size, in megabytes, of a workbook that can be loaded.'
$props += New-xDscResourceProperty -Name ExcelMemoryCacheThreshold -Type Sint32 -Attribute Write -Description 'The percentage of the Maximum Private Bytes that can be allocated to inactive objects. When the memory cache threshold is exceeded, cached objects that are not currently in use are released.'
$props += New-xDscResourceProperty -Name ExcelUnusedObjectAgeMax -Type Sint32 -Attribute Write -Description 'The maximum time (in minutes) that inactive objects remain in the memory cache. Inactive objects are objects that are not used in a session.'
$props += New-xDscResourceProperty -Name ExcelCachingUnusedFiles -Type Boolean -Attribute Write -Description 'Enable caching of files that are no longer in use by Web Excel sessions.'
$props += New-xDscResourceProperty -Name ExcelAbortOnRefreshOnOpenFail -Type Boolean -Attribute Write -Description 'Specifies that the loading of a Web Excel file automatically fails if an automatic data refresh operation fails when the file is opened.'
#Look online for valid values
$props += New-xDscResourceProperty -Name ExcelAutomaticVolatileFunctionCacheLifetime -Type Sint32 -Attribute Write -Description 'Specifies the maximum time, in seconds, that a computed value for a volatile function is cached for automatic recalculations.'
$props += New-xDscResourceProperty -Name ExcelConcurrentDataRequestsPerSessionMax -Type Sint32 -Attribute Write -Description 'Specifies the maximum number of concurrent external data requests allowed in each session. If a session must issue more than this number of requests, additional requests must be queued. The scope of this setting is the logical server.'
#look online for valid values
$props += New-xDscResourceProperty -Name ExcelDefaultWorkbookCalcMode -Type String -Attribute Write -Description 'Specifies the calculation mode of workbooks.  Settings other than File override the workbook settings.'
$props += New-xDscResourceProperty -Name ExcelRestExternalDataEnabled -Type Boolean -Attribute Write -Description 'Specifies whether requests from the Representational State Transfer (REST) Application Programming Interface (API) are permitted to refresh external data connections.'
$props += New-xDscResourceProperty -Name ExcelChartAndImageSizeMax -Type Sint32 -Attribute Write -Description 'Specifies the maximum size, in megabytes, of a chart or image that can be opened.'
$props += New-xDscResourceProperty -Name ExternalURL -Type String -Attribute Write -Description 'Specifies the URL root that clients use to access the Office Web Apps Server farm from the Internet. In the case of a load-balanced, multiserver Office Web Apps Server farm, the external URL is bound to the IP address of the external-facing load balancer.'
$props += New-xDscResourceProperty -Name FarmOU -Type String -Attribute Write -Description 'Specifies the name of the Active Directory organizational unit (OU) that servers must be a member of to join the Office Web Apps Server farm. Use this parameter to prevent unauthorized servers (that is, servers that are not in the OU) from joining an Office Web Apps Server farm.'
$props += New-xDscResourceProperty -Name InternalURL -Type String -Attribute Key -Description 'Specifies the URL root that clients use to access the Office Web Apps Server farm from the intranet.'
$props += New-xDscResourceProperty -Name LogLocation -Type String -Attribute Write -Description 'Specifies the location on the local computer where activity logs are stored.'
$props += New-xDscResourceProperty -Name LogRetentionInDays -Type Sint32 -Attribute Write -Description 'Specifies the number of days that log entries are stored. Log entries older than the configured date are trimmed.'
#look online for valid values
$props += New-xDscResourceProperty -Name LogVerbosity -Type String -Attribute Write -Description 'Specifies how much information is stored in the trace log files.'
$props += New-xDscResourceProperty -Name MaxMemoryCacheSizeInMB -Type Sint32 -Attribute Write -Description 'Specifies, in megabytes, the maximum amount of memory that the rendering cache can use.'
$props += New-xDscResourceProperty -Name MaxTranslationCharacterCount -Type Sint32 -Attribute Write -Description 'Specifies the maximum amount of characters a document can have in order to be translated.'
$props += New-xDscResourceProperty -Name OpenFromUncEnabled -Type Boolean -Attribute Write -Description 'Turns on or off the ability to use Online Viewers to view Office files from a UNC path.'
$props += New-xDscResourceProperty -Name OpenFromUrlEnabled -Type Boolean -Attribute Write -Description 'Turns on or off the ability to use Online Viewers to view Office files from a URL or UNC path.'
$props += New-xDscResourceProperty -Name OpenFromUrlThrottlingEnabled -Type Boolean -Attribute Write -Description 'Throttles the number of open from URL requests from any given server in a time period. The default throttling values, which are not configurable, make sure that an Office Web Apps Server farm will not overwhelm a single server with requests for content to be viewed in the Online Viewers.'
$props += New-xDscResourceProperty -Name Proxy -Type String -Attribute Write -Description 'Specifies the URL of the proxy server that is configured to allow HTTP requests to external sites. Typically configured in conjunction with the ClipartEnabled and TranslationEnabled parameters.'
$props += New-xDscResourceProperty -Name RecycleActiveProcessCount -Type Sint32 -Attribute Write -Description 'Specifies the number of files that a single Word or PowerPoint process can render before the process is recycled.'
$props += New-xDscResourceProperty -Name RenderingLocalCacheLocation -Type String -Attribute Write -Description 'Specifies the location of the temporary cache for use by the Word and PowerPoint Viewing Services.'
$props += New-xDscResourceProperty -Name SSLOffloaded -Type Boolean -Attribute Write -Description 'Indicates to the servers in the Office Web Apps Server farm that SSL is offloaded to the load balancer. When SSLOffloaded is enabled, web applications are bound to port 80 (HTTP) on the local server. However, HTML that references other resources, such as CSS or images, uses HTTPS URLs for those references.'
$props += New-xDscResourceProperty -Name TranslationEnabled -Type Boolean -Attribute Write -Description 'Enables support for automatic document translation using Microsoft Translator, an online service that translates text between languages. The translated file is shown in the Word Web App. Because Microsoft Translator is an online service, you must enable server-to-web communication directly or by using a proxy that you specify by using the Proxy parameter.'
$props += New-xDscResourceProperty -Name TranslationServiceAddress -Type String -Attribute Write -Description 'Specifies the URL of the translation server that translation requests are sent to. The default is the Microsoft Translator online service. Typically you will not use this parameter unless you must change translation services.'
$props += New-xDscResourceProperty -Name TranslationServiceAppId -Type String -Attribute Write -Description 'Specifies the application ID for the translation service. The default is the public application ID for Office Web Apps. Typically you will not use this parameter unless you have negotiated with Microsoft Translator for additional services and they have provided you with a private application ID.'
#These parameters exist but there is no documentation on them
$props += New-xDscResourceProperty -Name AllowOutboundHttp -Type Boolean -Attribute Write
$props += New-xDscResourceProperty -Name ExcelUseEffectiveUserName -Type Boolean -Attribute Write
$props += New-xDscResourceProperty -Name S2SCertificateName -Type String -Attribute Write
$Props += New-xDscResourceProperty -Name RemovePersonalInformationFromLogs -Type Boolean -Attribute Write
$props += New-xDscResourceProperty -Name PicturePasteDisabled -Type Boolean -Attribute Write


$newOfficeWeAppsFarmParams = @{

    Name = 'MSFT_xOfficeOnlineServerWebAppsFarm'
    Property = $props
    FriendlyName = 'xOfficeOnlineServerWebAppsFarm'
    ModuleName = 'xOfficeOnlineServer'
    Path = 'C:\Program Files\WindowsPowerShell\Modules\'
}

New-xDscResource @newOfficeWeAppsFarmParams