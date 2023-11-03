[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$script:DSCModuleName = 'OfficeOnlineServerDsc'
$script:DSCResourceName = 'MSFT_OfficeOnlineServerHost'
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

        Describe "MSFT_OfficeOnlineServerHost [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue

            # # Mock OfficeWebAppsHost .net object
            # $OfficeWebAppsHostObject = [scriptblock]::Create({
            #         New-Object -TypeName PSCustomObject -Property @{
            #             allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
            #         }
            #     })

            Mock -CommandName Get-OfficeWebAppsHost -MockWith {}
            Mock -CommandName Remove-OfficeWebAppsHost -MockWith {}
            Mock -CommandName New-OfficeWebAppsHost -MockWith {}
            Mock -CommandName Import-Module -MockWith {} -ParameterFilter {
                $Name -eq "OfficeWebApps"
            }

            Context "The Office Online Server PowerShell module can not be found" {
                $testParams = @{
                    AllowList        = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
                }

                Mock -CommandName Import-Module -MockWith {
                    throw "The specified module 'OfficeWebApps' was not loaded because no valid module file was found in any module directory."
                } -ParameterFilter {
                    $Name -eq "OfficeWebApps"
                }

                It "Throws an exception from 'Get-TargetResource'" {
                    { Get-TargetResource $testParams } | Should throw
                }

                It "Throws an exception from 'Test-TargetResource'" {
                    { Test-TargetResource $testParams } | Should throw
                }

                It "Throws an exception from 'Set-TargetResource'" {
                    { Set-TargetResource $testParams } | Should throw
                }
            }

            Context "Add new domain to allowlist" {
                $testParams = @{
                    AllowList        = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
                }

                Mock -CommandName Get-OfficeWebAppsHost -MockWith {
                    $instance = [PSCustomObject] @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    return $instance
                }

                It "Should return 'False' from 'Test-TargetResource'" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "Should call 'New-OfficeWebAppsHost' within 'Set-TargetResource'" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName New-OfficeWebAppsHost
                }
            }

            Context "Add existing domain to allowlist" {
                $testParams = @{
                    AllowList        = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
                }

                Mock -CommandName Get-OfficeWebAppsHost -MockWith {
                    $instance = [PSCustomObject] @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    $instance.allowList.Add("oos1.contoso.com")
                    return $instance
                }

                It "Should return 'Present' from 'Get-TargetResource'" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Should return 'True' from 'Test-TargetResource'" {
                    Test-TargetResource @testParams | Should Be $True
                }
            }

            Context "Remove existing domain from allowlist" {
                $testParams = @{
                    AllowList        = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
                    Ensure           = "Absent"
                }

                Mock -CommandName Get-OfficeWebAppsHost -MockWith {
                    $instance = [PSCustomObject] @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    $instance.allowList.Add("oos1.contoso.com")
                    return $instance
                }

                It "Should return 'False' from 'Test-TargetResource'" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "Should call 'Remove-OfficeWebAppsHost' within 'Set-TargetResource'" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName Remove-OfficeWebAppsHost
                }
            }

            Context "Remove existing domain from allowlist with multiple entries" {
                $testParams = @{
                    AllowList        = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
                    Ensure           = "Absent"
                }

                Mock -CommandName Get-OfficeWebAppsHost -MockWith {
                    $instance = [PSCustomObject] @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    $instance.allowList.Add("oos1.contoso.com")
                    $instance.allowList.Add("oos2.contoso.com")
                    $instance.allowList.Add("oos3.contoso.com")
                    return $instance
                }

                It "Should return 'False' from 'Test-TargetResource'" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "Should call 'Remove-OfficeWebAppsHost' within 'Set-TargetResource' exactly 1 time" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName Remove-OfficeWebAppsHost -Exactly -Times 1
                }
            }

            Context "Remove non existing domain from allowlist" {
                $testParams = @{
                    AllowList        = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
                    Ensure           = "Absent"
                }

                Mock -CommandName Get-OfficeWebAppsHost -MockWith {
                    $instance = [PSCustomObject] @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    $instance.allowList.Add("oos2.contoso.com")
                    return $instance
                }

                It "Should return 'True' from 'Test-TargetResource'" {
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

