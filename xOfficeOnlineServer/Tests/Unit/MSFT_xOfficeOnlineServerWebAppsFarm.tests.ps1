<#
.Synopsis
   Template for creating DSC Resource Unit Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Unit\ folder and rename <ResourceName>.tests.ps1 (e.g. MSFT_xFirewall.tests.ps1)
     2. Customize TODO sections.

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>


# TODO: Customize these parameters...
$Global:DSCModuleName      = 'xOfficeOnlineServer' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_xOfficeOnlineServerWebAppsFarm' # Example MSFT_xFirewall
# /TODO

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# TODO: Other Optional Init Code Goes Here...

# Begin Testing
try
{

    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        # TODO: Optopnal Load Mock for use in Pester tests here...
        #endregion
        $internalURL = "http://webfarm.contoso.com/"
        $externalURL = "http://external.contoso.com/"
        $proxy = 'http://proxy.contoso.com/'

        $mockWebFarm = @{
            FarmOU                                      = 'ldap://OU=Farm1'
            InternalURL                                 = @{AbsoluteUri = $internalURL}
            ExternalURL                                 = @{AbsoluteUri = $externalURL}
            AllowHTTP                                   = $True
            #AllowOutboundHttp                           = $False
            SSLOffloaded                                = $False
            CertificateName                             = 'Farm Cert'
            #S2SCertificateName                          = $null
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
            #TranslationServiceAppId                     = $null
            TranslationServiceAddress                   = 'http://tsa.contoso1.com/'
            RenderingLocalCacheLocation                 = 'C:\ProgramData\Microsoft\OfficeWebApps\Working\waccache'
            RecycleActiveProcessCount                   = 5
            AllowCEIP                                   = $True
            ExcelRequestDurationMax                     = 300
            ExcelSessionTimeout                         = 450
            ExcelWorkbookSizeMax                        = 10
            ExcelPrivateBytesMax                        = -1
            ExcelConnectionLifetime                     = 1800
            ExcelExternalDataCacheLifetime              = 300
            ExcelAllowExternalData                      = $True
            #ExcelUseEffectiveUserName                   = $False
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
            #PicturePasteDisabled                        = $True
            #RemovePersonalInformationFromLogs           = $False
            AllowHttpSecureStoreConnections             = $False
        }

        $mockWebFarmFalse = @{
            FarmOU                                      = 'Computers'
            InternalURL                                 = 'http://webfarm1.contoso.com/'
            ExternalURL                                 = 'http://webfarm1.contoso.com/'
            AllowHTTP                                   = $false
            #AllowOutboundHttp                           = $true
            SSLOffloaded                                = $true
            CertificateName                             = 'Farm Cert1'
            #S2SCertificateName                          = $null
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
            #ExcelUseEffectiveUserName                   = $true
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
            #PicturePasteDisabled                        = $false
            #RemovePersonalInformationFromLogs           = $true
            AllowHttpSecureStoreConnections             = $true
        }

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {



            Context 'Farm does not exist' {

                Mock Get-OfficeWebAppsFarm

                It 'Should return NULL values' {

                    $GetResult = Get-TargetResource -InternalURL $internalURL                    

                    foreach($Key in $GetResult.Keys)
                    {
                        $GetResult[$key] | Should be $null
                    }
                }

                It 'Should call expected mocks' {

                    Assert-MockCalled Get-OfficeWebAppsFarm -Exactly 1
                }
            }

            Context 'Farm does exist' {

                Mock Get-OfficeWebAppsFarm {$mockWebFarm}

                It 'Should return expected values' {
                    $GetResult = Get-TargetResource -InternalURL $internalURL

                    foreach($key in $mockWebFarm.Keys)
                    {
                        $GetResult[$key] | Should Be $mockWebFarm[$key]
                    }
                }

                It 'Should call expected mocks' {

                    Assert-MockCalled Get-OfficeWebAppsFarm -Exactly 1
                }
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
                $TestParams = $mockWebFarm.Clone()
                $TestParams.Remove('FarmOU')
                $TestParams.Add('FarmOU','Farm1')
                $TestParams.Add('Verbose',$true) 
                $TestParams.Remove('InternalURL')
                $TestParams.Add('InternalURL','http://webfarm.contoso.com')
                $TestParams.Remove('Proxy')
                $TestParams.Add('Proxy',$proxy)
                $TestParams.Remove('ExternalURL')
                $TestParams.Add('ExternalURL',$externalURL)

            Context 'Farm does not exist but should' {

                Mock Get-OfficeWebAppsFarm

                It 'Should return false' {

                    $TestResult = Test-TargetResource -InternalURL $internalURL

                    $TestResult | Should Be $false
                }
            }

            Context 'Farm exist with expected values' {
                Mock Get-OfficeWebAppsFarm { $mockWebFarm }
                Mock Compare-FarmOu { $true }

                It 'Should return true' {
                    {   
                        $TestResult = Test-TargetResource @TestParams

                        $TestResult | Should Be $true
                    } | Should Not Throw
                }

                It 'Should call expected mocks' {

                    Assert-MockCalled Get-OfficeWebAppsFarm -Times 1
                }
            }

            Context 'Farm exist with different values' {

                Mock Get-OfficeWebAppsFarm { $mockWebFarm }
                Mock Compare-FarmOu { $false }
                $FalseTestParams = @{InternalURL = $internalURL}
                $FalseTestParams.Add('Verbose',$true) 
                                
                foreach($key in $mockWebFarm.Keys)
                {
                    $FalseParams = $FalseTestParams.Clone()

                    If($key -ne 'InternalURL')
                    {
                        $FalseParams.Add($key,$mockWebFarmFalse[$key])                                                             
                    }
                    Else
                    {                        
                        $FalseParams.Remove('InternalURL')
                        $FalseParams.Add($key, $mockWebFarmFalse[$key])
                    }

                    It "Should return false testing: $key" {

                        $TestResult = Test-TargetResource @FalseParams

                        $TestResult | Should Be $false
                    }
                } 
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            
            Context 'Farm does not exist but should' {

                Mock Get-OfficeWebAppsFarm
                Mock New-OfficeWebAppsFarm

                It 'Should call New and not throw' {

                    { Set-TargetResource -InternalURL $internalURL -verbose} | Should Not Throw 
                }

                It 'Should call expected mocks' {

                    Assert-MockCalled Get-OfficeWebAppsFarm -Times 1
                    Assert-MockCalled New-OfficeWebAppsFarm -Times 1
                }
            }

            Context 'Farm does exist but not in a desired state' {
                Mock Get-OfficeWebAppsFarm -MockWith { $mockWebFarm }
                Mock Set-OfficeWebAppsFarm

                It 'Should call Set and not throw' {

                    {Set-TargetResource -InternalURL $internalURL -verbose} | Should Not Throw 
                }

                It 'Should call expected mocks' {

                    Assert-MockCalled Get-OfficeWebAppsFarm -Times 1
                    Assert-MockCalled Set-OfficeWebAppsFarm -Times 1
                }
            }
        }
        #endregion

        # TODO: Pester Tests for any Helper Cmdlets

    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
