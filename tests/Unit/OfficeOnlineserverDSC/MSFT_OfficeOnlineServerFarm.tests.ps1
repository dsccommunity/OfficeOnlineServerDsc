[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$script:DSCModuleName = 'OfficeOnlineServerDsc'
$script:DSCResourceName = 'MSFT_OfficeOnlineServerFarm'
$Global:CurrentWACCmdletModule = $WACCmdletModule

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DscResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $Script:DSCResourceName {
        $internalURL = "http://webfarm.contoso.com"
        $externalURL = "http://external.contoso.com"
        $proxy = 'http://proxy.contoso.com'

        $mockWebFarm = @{
            IsSingleInstance                            = 'Yes'
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
            IsSingleInstance                            = 'Yes'
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

        foreach ($param in $v16onlyParams)
        {
            if ($mockWebFarm.ContainsKey($param) -eq $true)
            {
                $mockWebFarm.Remove($param)
            }
            if ($mockWebFarmFalse.ContainsKey($param) -eq $true)
            {
                $mockWebFarmFalse.Remove($param)
            }
        }

        Mock -CommandName Test-Path -MockWith {
            return $false
        } -ParameterFilter { $_.Path -eq 'HKLM:\SOFTWARE\OOSDsc' }

        Describe "OfficeOnlineServerFarm [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {
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

            Context "A farm does not exist on the local machine, but should" {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    InternalUrl      = $internalURL
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
                    $getResult = Get-TargetResource -InternalURL $mockWebFarm.InternalUrl -IsSingleInstance $mockWebFarm.IsSingleInstance

                    foreach ($key in $mockWebFarm.Keys)
                    {
                        $getResult[$key] | Should Be $mockWebFarm[$key]
                    }
                }

                It "Returns true from the test method" {
                    Test-TargetResource @mockWebFarm | Should Be $true
                }
            }

            Context "Try to create farm without passing URL Parameter" {
                $thisContextMockWebFarm = $mockWebFarm.Clone()
                $thisContextMockWebFarm.Remove('ExternalURL')
                $thisContextMockWebFarm.Remove('InternalURL')

                It "test method should throw" {
                    { Test-TargetResource @thisContextMockWebFarm } | Should throw
                }
            }

            Context "An incorrectly configured farm is found locally" {

                Mock -CommandName Get-OfficeWebAppsFarm -MockWith {
                    return $mockWebFarmFalse
                }

                It "Returns the current values from the get method" {
                    (Get-TargetResource -InternalURL $mockWebFarm.InternalUrl -IsSingleInstance $mockWebFarm.IsSingleInstance).InternalUrl | Should Not BeNullOrEmpty
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
                    (Get-TargetResource -InternalURL $mockWebFarm.InternalUrl -IsSingleInstance 'Yes' ).InternalUrl | Should Not BeNullOrEmpty
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

                    $badParams = @{
                        IsSingleInstance  = 'Yes'
                        InternalUrl       = $internalURL
                        AllowOutboundHttp = $true
                    }

                    It "Throws in the get method" {
                        { Get-TargetResource @badParams } | Should Throw
                    }

                    It "Throws in the test method" {
                        { Test-TargetResource @badParams } | Should Throw
                    }

                    It "Throws in the set method" {
                        { Set-TargetResource @badParams } | Should Throw
                    }
                }
            }

            Context "Server is returning after a reboot after patching, do nothing" {
                $testParams = @{
                    InternalUrl      = $internalURL
                    IsSingleInstance = 'Yes'
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = "test"
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                        [CmdletBinding()]
                        param(
                            [Parameter(Mandatory = $true)]
                            [System.String]
                            $Input
                        )

                        return "Patching"
                    } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq 'HKLM:\SOFTWARE\OOSDsc' }

                It "Returns true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
