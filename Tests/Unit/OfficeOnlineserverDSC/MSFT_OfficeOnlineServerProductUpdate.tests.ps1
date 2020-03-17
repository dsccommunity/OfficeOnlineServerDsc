[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$Script:DSCModuleName      = 'OfficeOnlineServerDsc'
$Script:DSCResourceName    = 'MSFT_OfficeOnlineServerProductUpdate'
$Global:CurrentWACCmdletModule = $WACCmdletModule

[String] $moduleRoot = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\Modules\OfficeOnlineServerDsc" -Resolve
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
        Describe "OfficeOnlineServerInstall [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {

            Import-Module (Join-Path $PSScriptRoot "..\..\..\Modules\OfficeOnlineServerDsc" -Resolve)
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue

            Context "CU file does not exist" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup_not_exist.exe"
                    Servers = @("OOS1")
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                It "Throw exception in Get method" {
                    { Get-TargetResource @testParams } | Should Throw "Setup file cannot be found:"
                }

                It "Throw exception in Test method" {
                    { Test-TargetResource @testParams } | Should Throw "Setup file cannot be found:"
                }

                It "Throw exception in Set method" {
                    { Set-TargetResource @testParams } | Should Throw "Setup file cannot be found:"
                }
            }

            Context "OfficeVersion.inc file does not exist" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup_not_exist.exe"
                    Servers = @("OOS1")
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "C:\ProgramData\Microsoft\OfficeWebApps\Data\local\OfficeVersion.inc" }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                It "Throw exception in Get method" {
                    { Get-TargetResource @testParams } | Should Throw "Cannot find file "
                }

                It "Throw exception in Test method" {
                    { Test-TargetResource @testParams } | Should Throw "Cannot find file "
                }

                It "Throw exception in Set method" {
                    { Set-TargetResource @testParams } | Should Throw "Cannot find file "
                }
            }

            Context "Incorrect info in OfficeVersion.inc file" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup_not_exist.exe"
                    Servers = @("OOS1")
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
ERROR = 16
RMM = 0
RUP = 10353
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                It "Throw exception in Get method" {
                    { Get-TargetResource @testParams } | Should Throw "Cannot read Version information from file"
                }

                It "Throw exception in Test method" {
                    { Test-TargetResource @testParams } | Should Throw "Cannot read Version information from file"
                }
            }

            ## Servers not contain current server -> SET Method
            Context "Current server not in Servers variable" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1")
                }

                $env:COMPUTERNAME = "SERVER_NOT_IN_LIST"

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                It "Throw exception in Get method" {
                    { Get-TargetResource @testParams } | Should Throw "Parameter Servers should contain the current server name"
                }

                It "Throw exception in Test method" {
                    { Test-TargetResource @testParams } | Should Throw "Parameter Servers should contain the current server name"
                }

                It "Throw exception in Set method" {
                    { Set-TargetResource @testParams } | Should Throw "Parameter Servers should contain the current server name"
                }
            }

            Context "Ensure = Absent" {
                $testParams = @{
                    Ensure = "Absent"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1")
                }

                It "Throw exception in Get method" {
                    { Get-TargetResource @testParams } | Should Throw "Office Online Server does not support uninstalling updates."
                }

                It "Throw exception in Set method" {
                    { Set-TargetResource @testParams } | Should Throw "Office Online Server does not support uninstalling updates."
                }
            }

            Context "Unknown exit code during install" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1")
                }

                $env:COMPUTERNAME = "OOS1"

                Mock -CommandName Invoke-Command -MockWith {
                    return @{
                        Machines      = "OOS1"
                        MasterMachine = $testParams.Servers
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                        NewMaster     = "OOS1"
                        Name          = "OOS1"
                    }
                }

                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {}

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
                }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10353
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 9999
                    }
                }

                Mock -CommandName New-Item -MockWith {}
                Mock -CommandName New-ItemProperty -MockWith {}

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    { Set-TargetResource @testParams } | Should Throw "Office Online Server update install failed, exit code was"
                }
            }

            Context "CU is not installed, but should be - Single server" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1")
                }

                $env:COMPUTERNAME = "OOS1"

                Mock -CommandName Invoke-Command -MockWith {
                    return @{
                        Machines      = "OOS1"
                        MasterMachine = $testParams.Servers
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                        NewMaster     = "OOS1"
                        Name          = "OOS1"
                    }
                }

                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {}

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
                }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10353
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 0
                    }
                }

                Mock -CommandName New-Item -MockWith {}
                Mock -CommandName New-ItemProperty -MockWith {}

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                    $global:DSCMachineStatus | Should Be 1
                }
            }

            Context "CU is not installed, but should be - Master server, last server in farm" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1","OOS2")
                }

                $env:COMPUTERNAME = "OOS1"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                        NewMaster     = "OOS2"
                    }

                    if ($global:srvCounter -eq 1)
                    {
                        $returnval.Name          = "OOS1"
                        $returnval.Machines      = @("OOS1")
                        $returnval.MasterMachine = "OOS1"
                        $returnval.Version       = "16.0.10353.20001"
                    }
                    else
                    {
                        $returnval.Name          = "OOS2"
                        $returnval.Machines      = @("OOS2")
                        $returnval.MasterMachine = "OOS2"
                        $returnval.Version       = "16.0.10354.20001"
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {}

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
                }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10353
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 0
                    }
                }

                Mock -CommandName New-Item -MockWith {}
                Mock -CommandName New-ItemProperty -MockWith {}

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                    $global:DSCMachineStatus | Should Be 1
                }
            }

            Context "CU is not installed, but should be - Master server, not last server in farm" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1","OOS2")
                }

                $env:COMPUTERNAME = "OOS1"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                        NewMaster     = "OOS2"
                        Machines      = @("OOS1","OOS2")
                        MasterMachine = "OOS1"
                    }

                    if ($global:srvCounter -eq 1)
                    {
                        $returnval.Name          = "OOS1"
                        $returnval.Version       = "16.0.10353.20001"
                    }
                    else
                    {
                        $returnval.Name          = "OOS2"
                        $returnval.Version       = "16.0.10353.20001"
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {}

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
                }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10353
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 0
                    }
                }

                Mock -CommandName New-Item -MockWith {}
                Mock -CommandName New-ItemProperty -MockWith {}

                $global:SleepCounter = 0
                Mock -CommandName Start-Sleep -MockWith {
                    $global:SleepCounter++
                }

                Mock -CommandName Get-OfficeWebAppsFarm -MockWith {
                    if ($global:SleepCounter -lt 25)
                    {
                        return @{
                            Machines = @(
                                @{
                                    MachineName = "OOS1"
                                },
                                @{
                                    MachineName = "OOS2"
                                }
                            )
                        }
                    }
                    else
                    {
                        return @{
                            Machines = @(
                                @{
                                    MachineName = "OOS1"
                                }
                            )
                        }
                    }
                }




                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                    $global:SleepCounter | Should Be 25 # Looped through Sleep code 25 times
                    $global:DSCMachineStatus | Should Be 1
                }
            }

            Context "CU is not installed, but should be - Master server, resume install as master server. Create new farm." {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1")
                }

                $env:COMPUTERNAME = "OOS1"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                        NewMaster     = "OOS1"
                    }

                    if ($global:srvCounter -eq 1)
                    {
                        $returnval.Name          = "OOS1"
                        $returnval.Version       = "16.0.10354.20001"
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName New-OfficeWebAppsFarm -MockWith {}

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
                }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            [CmdletBinding()]
                            param(
                                [Parameter(Mandatory = $true)]
                                [System.String]
                                $Input
                            )

                            if ($Input -eq "State")
                            {
                                return "Patching"
                            }
                            else
                            {
                                return @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null
}
"@
                            }
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10354
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName Remove-Item -MockWith {}

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled New-OfficeWebAppsFarm
                }
            }

            Context "CU is not installed, but should be - Master server, resume install and join other farm" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1","OOS2")
                }

                $env:COMPUTERNAME = "OOS1"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                        NewMaster     = "OOS2"
                    }

                    if ($global:srvCounter -eq 1)
                    {
                        $returnval.Name          = "OOS1"
                        $returnval.Version       = "16.0.10354.20001"
                    }
                    else
                    {
                        $returnval.Name          = "OOS2"
                        $returnval.Version       = "16.0.10354.20001"
                        $returnval.Machines      = @("OOS2")
                        $returnval.MasterMachine = "OOS2"
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
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

                            if ($Input -eq "State")
                            {
                                return "Patching"
                            }
                            else
                            {
                                return "All"
                            }
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10354
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName New-OfficeWebAppsMachine -MockWith {}

                Mock -CommandName Remove-Item -MockWith {}

                Mock -CommandName Get-OfficeWebAppsFarm -MockWith {
                    if ($global:SleepCounter -lt 25)
                    {
                        return @{
                            Machines = @(
                                @{
                                    MachineName = "OOS1"
                                },
                                @{
                                    MachineName = "OOS2"
                                }
                            )
                        }
                    }
                    else
                    {
                        return @{
                            Machines = @(
                                @{
                                    MachineName = "OOS1"
                                }
                            )
                        }
                    }
                }

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled New-OfficeWebAppsMachine
                    Assert-MockCalled Remove-Item
                }
            }

            Context "CU is not installed, but should be - Not Master server, first patched server, create new farm" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1","OOS2")
                }

                $env:COMPUTERNAME = "OOS2"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                        NewMaster     = $null
                        Machines      = @("OOS1","OOS2")
                        MasterMachine = "OOS1"
                    }

                    if ($global:srvCounter -eq 1)
                    {
                        $returnval.Name          = "OOS1"
                        $returnval.Version       = "16.0.10353.20001"
                    }
                    else
                    {
                        $returnval.Name          = "OOS2"
                        $returnval.Version       = "16.0.10353.20001"
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {}

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
                }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10353
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 0
                    }
                }

                Mock -CommandName New-Item -MockWith {}
                Mock -CommandName New-ItemProperty -MockWith {}

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                    $global:DSCMachineStatus | Should Be 1
                }
            }

            ### CU Is not installed: Not Master server, not first patched server -> Install and join other master server
            Context "CU is not installed, but should be - Not Master server, second patched server, join new farm" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1","OOS2","OOS3")
                }

                $env:COMPUTERNAME = "OOS2"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                    }

                    switch ($global:srvCounter)
                    {
                        1 {
                            $returnval.Name          = "OOS1"
                            $returnval.Version       = "16.0.10353.20001"
                            $returnval.Machines      = @("OOS1","OOS2")
                            $returnval.MasterMachine = "OOS1"
                            $returnval.NewMaster     = "OOS1"
                        }
                        2 {
                            $returnval.Name          = "OOS2"
                            $returnval.Version       = "16.0.10353.20001"
                            $returnval.Machines      = @("OOS1","OOS2")
                            $returnval.MasterMachine = "OOS1"
                            $returnval.NewMaster     = "OOS1"
                        }
                        3 {
                            $returnval.Name          = "OOS3"
                            $returnval.Version       = "16.0.10354.20001"
                            $returnval.Machines      = @("OOS3")
                            $returnval.MasterMachine = "OOS3"
                            $returnval.NewMaster     = "OOS3"
                        }
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {}

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
                }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            return ""
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10353
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 0
                    }
                }

                Mock -CommandName New-Item -MockWith {}
                Mock -CommandName New-ItemProperty -MockWith {}

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                    $global:DSCMachineStatus | Should Be 1
                }
            }

            Context "CU is not installed, but should be - Not Master server, resume install as master server. Create new farm." {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1","OOS2","OOS3")
                }

                $env:COMPUTERNAME = "OOS3"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                    }

                    switch ($global:srvCounter)
                    {
                        1 {
                            $returnval.Name          = "OOS1"
                            $returnval.Version       = "16.0.10353.20001"
                            $returnval.Machines      = @("OOS1","OOS2")
                            $returnval.MasterMachine = "OOS1"
                            $returnval.NewMaster     = "OOS1"
                        }
                        2 {
                            $returnval.Name          = "OOS2"
                            $returnval.Version       = "16.0.10353.20001"
                            $returnval.Machines      = @("OOS1","OOS2")
                            $returnval.MasterMachine = "OOS1"
                            $returnval.NewMaster     = "OOS1"
                        }
                        3 {
                            $returnval.Name          = "OOS3"
                            $returnval.Version       = "16.0.10354.20001"
                            $returnval.Machines      = $null
                            $returnval.MasterMachine = $null
                            $returnval.NewMaster     = "OOS3"
                        }
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName New-OfficeWebAppsFarm -MockWith {}

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
                }

                Mock -CommandName Get-Item -MockWith {
                    $returnval = ""
                    $returnval = $returnval | Add-Member -MemberType ScriptMethod `
                        -Name GetValue `
                        -Value {
                            [CmdletBinding()]
                            param(
                                [Parameter(Mandatory = $true)]
                                [System.String]
                                $Input
                            )

                            if ($Input -eq "State")
                            {
                                return "Patching"
                            }
                            else
                            {
                                return @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null
}
"@
                            }
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10354
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName Remove-Item -MockWith {}

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled New-OfficeWebAppsFarm
                }
            }

            Context "CU is not installed, but should be - Not Master server, resume install and join other farm" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1","OOS2","OOS3")
                }

                $env:COMPUTERNAME = "OOS2"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                    }

                    switch ($global:srvCounter)
                    {
                        1 {
                            $returnval.Name          = "OOS1"
                            $returnval.Version       = "16.0.10353.20001"
                            $returnval.Machines      = @("OOS1","OOS2")
                            $returnval.MasterMachine = "OOS1"
                            $returnval.NewMaster     = "OOS1"
                        }
                        2 {
                            $returnval.Name          = "OOS2"
                            $returnval.Version       = "16.0.10354.20001"
                            $returnval.Machines      = $null
                            $returnval.MasterMachine = $null
                            $returnval.NewMaster     = "OOS3"
                        }
                        3 {
                            $returnval.Name          = "OOS3"
                            $returnval.Version       = "16.0.10354.20001"
                            $returnval.Machines      = @("OOS3")
                            $returnval.MasterMachine = "OOS3"
                            $returnval.NewMaster     = "OOS3"
                        }
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
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

                            if ($Input -eq "State")
                            {
                                return "Patching"
                            }
                            else
                            {
                                return "All"
                            }
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10354
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName New-OfficeWebAppsMachine -MockWith {}

                Mock -CommandName Remove-Item -MockWith {}

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled New-OfficeWebAppsMachine
                    Assert-MockCalled Remove-Item
                }
            }

            ### CU Is not installed: No role known -> New server, just install patch
            Context "CU is not installed, but should be - New server, no role known, just install patch" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1","OOS2")
                }

                $env:COMPUTERNAME = "OOS1"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = $null
                        Config        = $null
                    }

                    switch ($global:srvCounter)
                    {
                        1 {
                            $returnval.Name          = "OOS1"
                            $returnval.Version       = "16.0.10354.20001"
                            $returnval.Machines      = $null
                            $returnval.MasterMachine = $null
                            $returnval.NewMaster     = "OOS1"
                        }
                        2 {
                            $returnval.Name          = "OOS2"
                            $returnval.Version       = "16.0.10354.20001"
                            $returnval.Machines      = $null
                            $returnval.MasterMachine = $null
                            $returnval.NewMaster     = "OOS1"
                        }
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
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

                            return $null
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10353
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 0
                    }
                }

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                $global:DSCMachineStatus = 0
                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                    $global:DSCMachineStatus | Should Be 1
                }
            }

            ### CU Is installed
            Context "CU is installed and should be" {
                $testParams = @{
                    Ensure = "Present"
                    SetupFile = "C:\InstallFiles\setup.exe"
                    Servers = @("OOS1","OOS2")
                }

                $env:COMPUTERNAME = "OOS1"

                $global:srvCounter = 1
                Mock -CommandName Invoke-Command -MockWith {
                    $returnval = @{
                        Roles         = "All"
                        Config        = @"
{
    "FarmOU":  "",
    "InternalURL":  "https://oos.portal.politie.local/",
    "ExternalURL":  null,
    "AllowHTTP":  false,
    "AllowOutboundHttp":  false,
    "SSLOffloaded":  false,
    "CertificateName":  "*.portal.politie.local",
    "S2SCertificateName":  "",
    "EditingEnabled":  true,
    "LogLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Data\\Logs\\ULS",
    "LogRetentionInDays":  7,
    "LogVerbosity":  "",
    "Proxy":  null,
    "CacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\d",
    "MaxMemoryCacheSizeInMB":  75,
    "DocumentInfoCacheSize":  5000,
    "CacheSizeInGB":  15,
    "ClipartEnabled":  false,
    "TranslationEnabled":  false,
    "MaxTranslationCharacterCount":  125000,
    "TranslationServiceAppId":  "",
    "TranslationServiceAddress":  "",
    "RenderingLocalCacheLocation":  "C:\\ProgramData\\Microsoft\\OfficeWebApps\\Working\\waccache",
    "RecycleActiveProcessCount":  5,
    "AllowCEIP":  false,
    "ExcelRequestDurationMax":  300,
    "ExcelSessionTimeout":  450,
    "ExcelWorkbookSizeMax":  30,
    "ExcelPrivateBytesMax":  -1,
    "ExcelConnectionLifetime":  1800,
    "ExcelExternalDataCacheLifetime":  300,
    "ExcelAllowExternalData":  true,
    "ExcelUseEffectiveUserName":  false,
    "ExcelWarnOnDataRefresh":  true,
    "ExcelUdfsAllowed":  false,
    "ExcelMemoryCacheThreshold":  85,
    "ExcelUnusedObjectAgeMax":  -1,
    "ExcelCachingUnusedFiles":  true,
    "ExcelAbortOnRefreshOnOpenFail":  true,
    "ExcelAutomaticVolatileFunctionCacheLifeTime":  300,
    "ExcelConcurrentDataRequestsPerSessionMax":  5,
    "ExcelDefaultWorkbookCalcMode":  0,
    "ExcelRestExternalDataEnabled":  true,
    "ExcelChartAndImageSizeMax":  1,
    "OpenFromUrlEnabled":  false,
    "OpenFromUncEnabled":  true,
    "OpenFromUrlThrottlingEnabled":  true,
    "PicturePasteDisabled":  true,
    "RemovePersonalInformationFromLogs":  false,
    "AllowHttpSecureStoreConnections":  false
}
"@
                    }

                    switch ($global:srvCounter)
                    {
                        1 {
                            $returnval.Name          = "OOS1"
                            $returnval.Version       = "16.0.10354.20001"
                            $returnval.Machines      = @("OOS1","OOS2")
                            $returnval.MasterMachine = "OOS1"
                            $returnval.NewMaster     = "OOS1"
                        }
                        2 {
                            $returnval.Name          = "OOS2"
                            $returnval.Version       = "16.0.10354.20001"
                            $returnval.Machines      = @("OOS1","OOS2")
                            $returnval.MasterMachine = "OOS1"
                            $returnval.NewMaster     = "OOS1"
                        }
                    }

                    $global:srvCounter++

                    return $returnval
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-Item -MockWith {
                    return $null
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

                            return $null
                        } -PassThru -Force

                    return $returnval
                } -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\OOSDsc" }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        VersionInfo = @{
                            FileVersion = "16.0.10354.20001"
                        }
                    }
                }

                Mock -CommandName Get-Content -MockWith {
                    $returnval = @"
# Version Numbers Makefile Include

# While the actual version of all assemblies will be 16.0.0.0, and all references to
# the filesystem will be web server extensions\16, and all references to the registry
# likewise '16.0', the OM of SharePoint will remain compatibilityLevel == 15 (the
# 2013 user experience).  This necessitates a constant for the current 'maximum'
# compatibilityLevel, and other code will still need to refer to the actual product
# version as a separate entity.
SERVER_COMPAT_RMJ = 15
WSS_RMJ = 4
RMJ = 16
RMM = 0
RUP = 10354
RPR = 20001
ISBUILDLABMACHINE = 0
"@
                    return $returnval
                }

                Mock -CommandName New-OfficeWebAppsMachine -MockWith {}

                Mock -CommandName Remove-Item -MockWith {}

                It "Returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
