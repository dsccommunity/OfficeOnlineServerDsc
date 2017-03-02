[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$Script:DSCModuleName      = 'OfficeOnlineServerDsc'
$Script:DSCResourceName    = 'MSFT_OfficeOnlineServerWebAppsFarm'
$Global:CurrentWACCmdletModule = $WACCmdletModule

[String] $moduleRoot = Join-Path -Path $PSScriptRoot -ChildPath "..\..\Modules\OfficeOnlineServerDsc" -Resolve
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Script:DSCModuleName `
    -DSCResourceName $Script:DSCResourceName `
    -TestType Unit 

try
{
    InModuleScope $Script:DSCResourceName {

        Import-Module (Join-Path ((Resolve-Path $PSScriptRoot\..\..).Path) "Modules\OfficeOnlineServerDsc\OfficeOnlineServerDsc.psd1")
        $internalURL = "http://webfarm.contoso.com"
        $externalURL = "http://external.contoso.com"
        $proxy = 'http://proxy.contoso.com'

        $mockWebFarm = @{
            FarmOU                                      = 'ldap://OU=Farm1'
            InternalURL                                 = [System.Uri]::new($internalURL.TrimEnd('/') + "/")
            ExternalURL                                 = [System.Uri]::new($externalURL.TrimEnd('/') + "/")
            AllowHTTP                                   = $True
            SSLOffloaded                                = $False
            CertificateName                             = 'Farm Cert'
            EditingEnabled                              = $True
            LogLocation                                 = 'C:\Logs'
            LogRetentionInDays                          = 7
            LogVerbosity                                = 'Verbose'
            Proxy                                       = [System.Uri]::new($proxy)
            CacheLocation                               = 'C:\ProgramData\Microsoft\OfficeWebApps\Working\d'
            MaxMemoryCacheSizeInMB                      = 75
            DocumentInfoCacheSize                       = 5000
            CacheSizeInGB                               = 15
            ClipartEnabled                              = $False
            TranslationEnabled                          = $False
            MaxTranslationCharacterCount                = 125000
            TranslationServiceAddress                   = 'http://tsa.contoso1.com/'
            RenderingLocalCacheLocation                 = 'C:\ProgramData\Microsoft\OfficeWebApps\Working\waccache'
            RecycleActiveProcessCount                   = 5
            AllowCEIP                                   = $true
            ExcelRequestDurationMax                     = 300
            ExcelSessionTimeout                         = 450
            ExcelWorkbookSizeMax                        = 10
            ExcelPrivateBytesMax                        = -1
            ExcelConnectionLifetime                     = 1800
            ExcelExternalDataCacheLifetime              = 300
            ExcelAllowExternalData                      = $True
            ExcelWarnOnDataRefresh                      = $True
            ExcelUdfsAllowed                            = $False
            ExcelMemoryCacheThreshold                   = 90
            ExcelUnusedObjectAgeMax                     = -1
            ExcelCachingUnusedFiles                     = $True
            ExcelAbortOnRefreshOnOpenFail               = $True
            ExcelAutomaticVolatileFunctionCacheLifeTime = 300
            ExcelConcurrentDataRequestsPerSessionMax    = 5
            ExcelDefaultWorkbookCalcMode                = 'File'
            ExcelRestExternalDataEnabled                = $True
            ExcelChartAndImageSizeMax                   = 1
            OpenFromUrlEnabled                          = $False
            OpenFromUncEnabled                          = $True
            OpenFromUrlThrottlingEnabled                = $True
            AllowHttpSecureStoreConnections             = $False
        }

        $mockWebFarmFalse = @{
            FarmOU                                      = 'Computers'
            InternalURL                                 = 'http://webfarm1.contoso.com/'
            ExternalURL                                 = 'http://webfarm1.contoso.com/'
            AllowHTTP                                   = $false
            SSLOffloaded                                = $true
            CertificateName                             = 'Farm Cert1'
            EditingEnabled                              = $false
            LogLocation                                 = 'C:\Logs1'
            LogRetentionInDays                          = 8
            LogVerbosity                                = 'VerboseEX'
            Proxy                                       = 'http://prox1.contoso.com/'
            CacheLocation                               = 'C:\ProgramData\Microsoft\OfficeWebApps\Working\d1'
            MaxMemoryCacheSizeInMB                      = 1500
            DocumentInfoCacheSize                       = 2500
            CacheSizeInGB                               = 8
            ClipartEnabled                              = $true
            TranslationEnabled                          = $true
            MaxTranslationCharacterCount                = 125001
            TranslationServiceAppId                     = 'NULL'
            TranslationServiceAddress                   = 'http://tsa.contoso.com/'
            RenderingLocalCacheLocation                 = 'C:\ProgramData\Microsoft\OfficeWebApps\Working\waccache1'
            RecycleActiveProcessCount                   = 10
            AllowCEIP                                   = $false
            ExcelRequestDurationMax                     = 600
            ExcelSessionTimeout                         = 900
            ExcelWorkbookSizeMax                        = 20
            ExcelPrivateBytesMax                        = 11
            ExcelConnectionLifetime                     = 1801
            ExcelExternalDataCacheLifetime              = 301
            ExcelAllowExternalData                      = $false
            ExcelWarnOnDataRefresh                      = $false
            ExcelUdfsAllowed                            = $true
            ExcelMemoryCacheThreshold                   = 180
            ExcelUnusedObjectAgeMax                     = 125
            ExcelCachingUnusedFiles                     = $false
            ExcelAbortOnRefreshOnOpenFail               = $false
            ExcelAutomaticVolatileFunctionCacheLifeTime = 150
            ExcelConcurrentDataRequestsPerSessionMax    = 3
            ExcelDefaultWorkbookCalcMode                = 'Auto'
            ExcelRestExternalDataEnabled                = $false
            ExcelChartAndImageSizeMax                   = 2
            OpenFromUrlEnabled                          = $true
            OpenFromUncEnabled                          = $false
            OpenFromUrlThrottlingEnabled                = $false
            AllowHttpSecureStoreConnections             = $true
        }

        $v16onlyParams = @("AllowOutboundHttp", "S2SCertificateName", "OnlinePictureEnabled", `
                          "OnlineVideoEnabled", "OfficeAddinEnabled", `
                          "ExcelUseEffectiveUserName", "ExcelUdfsAllowed", `
                          "ExcelMemoryCacheThreshold", "ExcelUnusedObjectAgeMax", `
                          "ExcelCachingUnusedFiles", "ExcelAbortOnRefreshOnOpenFail", `
                          "ExcelAutomaticVolatileFunctionCacheLifeTime", `
                          "ExcelConcurrentDataRequestsPerSessionMax", `
                          "ExcelDefaultWorkbookCalcMode", "ExcelRestExternalDataEnabled", `
                          "ExcelChartAndImageSizeMax")

        foreach ($param in $v16onlyParams) {
            if ($mockWebFarm.ContainsKey($param) -eq $true) {
                $mockWebFarm.Remove($param)
            }
            if ($mockWebFarmFalse.ContainsKey($param) -eq $true) {
                $mockWebFarmFalse.Remove($param)
            }
        }

        Describe "OfficeOnlineServerWebAppsFarm [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {

            Import-Module (Join-Path $PSScriptRoot "..\..\Modules\OfficeOnlineServerDsc" -Resolve)
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue 

            if ($Global:CurrentWACCmdletModule.Contains("15") -eq $true)
            {
                Mock -CommandName Get-OosDscInstalledProductVersion -MockWith {
                    return [Version]::Parse("15.0.0.0")
                }
            }
            if ($Global:CurrentWACCmdletModule.Contains("16") -eq $true)
            {
                Mock -CommandName Get-OosDscInstalledProductVersion -MockWith {
                    return [Version]::Parse("16.0.0.0")
                }
            }
            

            Mock -CommandName New-OfficeWebAppsFarm -MockWith { }
            Mock -CommandName Set-OfficeWebAppsFarm -MockWith { }
            Mock -CommandName Test-OosDscFarmOu -MockWith { return $true }

            Context "A farm does not exist on the local macine, but should" {
                $testParams = @{
                    InternalUrl = $internalURL
                }

                Mock -CommandName Get-OfficeWebAppsFarm -MockWith { 
                    throw "It does not appear that this machine is part of an Office Online Server Farm."
                }

                It "Returns no internal URL from the get method" {
                    (Get-TargetResource @testParams).InternalUrl | Should BeNullOrEmpty
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "Creates the farm in the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled New-OfficeWebAppsFarm
                }
            }

            Context "A correctly configured farm is found locally" {

                Mock -CommandName Get-OfficeWebAppsFarm -MockWith { 
                    return $mockWebFarm
                }

                It "Returns the current values from the get method" {
                    $getResult = Get-TargetResource -InternalURL $mockWebFarm.InternalUrl

                    foreach($key in $mockWebFarm.Keys)
                    {
                        $getResult[$key] | Should Be $mockWebFarm[$key]
                    }
                }

                It "Returns true from the test method" {
                    Test-TargetResource @mockWebFarm | Should Be $true
                }
            }

            Context "An incorrectly configured farm is found locally" {

                Mock -CommandName Get-OfficeWebAppsFarm -MockWith { 
                    return $mockWebFarmFalse
                }

                It "Returns the current values from the get method" {
                    (Get-TargetResource -InternalURL $mockWebFarm.InternalUrl).InternalUrl | Should Not BeNullOrEmpty
                }

                It "Returns false from the test method" {
                    Test-TargetResource @mockWebFarm | Should Be $false
                }

                It "Updates the farm in the set method" {
                    Set-TargetResource @mockWebFarm
                    Assert-MockCalled Set-OfficeWebAppsFarm
                }
            }

            Context "A farm with an incorrect OU exists locally" {
                
                $mockBadOu = $mockWebFarm
                $mockBadOu.FarmOu = 'ldap://OU=WrongOU'

                Mock -CommandName Get-OfficeWebAppsFarm -MockWith { 
                    return $mockWebFarm
                }

                Mock Test-OosDscFarmOu { return $false }

                It "Returns the current values from the get method" {
                    (Get-TargetResource -InternalURL $mockWebFarm.InternalUrl).InternalUrl | Should Not BeNullOrEmpty
                }

                It "Returns false from the test method" {
                    Test-TargetResource @mockBadOu | Should Be $false
                }

                It "Updates the farm in the set method" {
                    Set-TargetResource @mockBadOu
                    Assert-MockCalled Set-OfficeWebAppsFarm
                }
            }

            if ($Global:CurrentWACCmdletModule.Contains("15") -eq $true)
            {
                Context "Errors are thrown when incorrect parameters are used for Office Web Apps 2013" {
                    It "Throws in the get method" {
                        { Get-TargetResource -InternalUrl $internalURL -AllowOutboundHttp:$true } | Should Throw
                    }

                    It "Throws in the test method" {
                        { Test-TargetResource -InternalUrl $internalURL -AllowOutboundHttp:$true } | Should Throw
                    }

                    It "Throws in the set method" {
                        { Set-TargetResource -InternalUrl $internalURL -AllowOutboundHttp:$true } | Should Throw
                    }
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
