[CmdletBinding()]
param(
    [string] $WACCmdletModule = (Join-Path $PSScriptRoot "\Stubs\Office15.WACServer\OfficeWebApps.psm1" -Resolve)
)

$Global:DSCModuleName      = 'OfficeOnlineServerDsc'
$Global:DSCResourceName    = 'MSFT_OfficeOnlineServerWebAppsFarm'
$Global:CurrentWACCmdletModule = $WACCmdletModule

[String] $moduleRoot = Join-Path -Path $PSScriptRoot -ChildPath "..\..\Modules\OfficeOnlineServerDsc" -Resolve
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 

try
{
    InModuleScope $Global:DSCResourceName {

        Import-Module (Join-Path ((Resolve-Path $PSScriptRoot\..\..).Path) "Modules\OfficeOnlineServerDsc\OfficeOnlineServerDsc.psd1")
        $internalURL = "http://webfarm.contoso.com/"
        $externalURL = "http://external.contoso.com/"
        $proxy = 'http://proxy.contoso.com/'

        $mockWebFarm = @{
            FarmOU                                      = 'ldap://OU=Farm1'
            InternalURL                                 = @{AbsoluteUri = $internalURL}
            ExternalURL                                 = @{AbsoluteUri = $externalURL}
            AllowHTTP                                   = $True
            SSLOffloaded                                = $False
            CertificateName                             = 'Farm Cert'
            EditingEnabled                              = $True
            LogLocation                                 = 'C:\Logs'
            LogRetentionInDays                          = 7
            LogVerbosity                                = 'Verbose'
            Proxy                                       = @{AbsoluteUri = $proxy}
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

        Describe "xOfficeOnlineServerWebAppsFarm [Simulating $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {

            Import-Module (Join-Path $PSScriptRoot "..\..\Modules\OfficeOnlineServerDsc" -Resolve)
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue 
            

            Mock -CommandName New-OfficeWebAppsFarm -MockWith { }
            Mock -CommandName Set-OfficeWebAppsFarm -MockWith { }
            Mock -CommandName Test-OosDscFarmOu -MockWith { return $true }

            Context "A farm does not exist on the local macine, but should" {
                $testParams = @{
                    InternalUrl = $internalURL
                }

                It "returns no internal URL from the get method" {
                    (Get-TargetResource @testParams).InternalUrl | Should BeNullOrEmpty
                }

                It "returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "creates the farm in the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled New-OfficeWebAppsFarm
                }
            }

            Context "A correctly configured farm is found locally" {

                Mock -CommandName Get-OfficeWebAppsFarm -MockWith { 
                    return $mockWebFarm
                }

                It "returns the current values from the get method" {
                    $GetResult = Get-TargetResource -InternalURL $mockWebFarm.InternalUrl

                    foreach($key in $mockWebFarm.Keys)
                    {
                        $GetResult[$key] | Should Be $mockWebFarm[$key]
                    }
                }

                It "returns true from the test method" {
                    Test-TargetResource @mockWebFarm | Should Be $true
                }
            }

            Context "An incorrectly configured farm is found locally" {

                Mock -CommandName Get-OfficeWebAppsFarm -MockWith { 
                    return $mockWebFarmFalse
                }

                It "returns the current values from the get method" {
                    (Get-TargetResource -InternalURL $mockWebFarm.InternalUrl).InternalUrl | Should Not BeNullOrEmpty
                }

                It "returns false from the test method" {
                    Test-TargetResource @mockWebFarm | Should Be $false
                }

                It "updates the farm in the set method" {
                    Set-TargetResource @mockWebFarm
                    Assert-MockCalled Set-OfficeWebAppsFarm
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
