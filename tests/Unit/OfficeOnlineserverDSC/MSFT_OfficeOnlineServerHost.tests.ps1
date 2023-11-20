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
                    Domain           = "oos1.contoso.com"
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

            Context "Add new domain" {
                $testParams = @{
                    Domains          = "oos1.contoso.com"
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
                    Assert-MockCalled -CommandName New-OfficeWebAppsHost -Exactly -Times 1
                }
            }

            Context "Add existing domain" {
                $testParams = @{
                    Domains          = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
                }

                Mock -CommandName Get-OfficeWebAppsHost -MockWith {
                    $instance = [PSCustomObject] @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    $instance.allowList.Add("oos1.contoso.com")
                    return $instance
                }

                It "Should return 'True' from 'Test-TargetResource'" {
                    Test-TargetResource @testParams | Should Be $True
                }
            }

            Context "Remove existing domain" {
                $testParams = @{
                    DomainsToExclude = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
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

            Context "Remove non existing domain" {
                $testParams = @{
                    DomainsToExclude = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
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

                It "Should not call 'Remove-OfficeWebAppsHost' within 'Set-TargetResource'" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName Remove-OfficeWebAppsHost -Exactly -Times 0
                }
            }

            Context "Remove all existing domain" {
                $testParams = @{
                    Domains          = @()
                    IsSingleInstance = "Yes"
                }

                Mock -CommandName Get-OfficeWebAppsHost -MockWith {
                    $instance = [PSCustomObject] @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    $instance.allowList.Add("oos1.contoso.com")
                    $instance.allowList.Add("oos2.contoso.com")
                    return $instance
                }

                It "Should return 'False' from 'Test-TargetResource'" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "Should not call 'Remove-OfficeWebAppsHost' within 'Set-TargetResource'" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName Remove-OfficeWebAppsHost -Exactly -Times 2
                }
            }

            Context "Add new domain and remove existing domain" {
                $testParams = @{
                    DomainsToExclude = "oos1.contoso.com"
                    DomainsToInclude = "oos10.contoso.com"
                    IsSingleInstance = "Yes"
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

                It "Should call 'New-OfficeWebAppsHost' and 'Remove-OfficeWebAppsHost' within 'Set-TargetResource'" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName Remove-OfficeWebAppsHost -Exactly -Times 1
                    Assert-MockCalled -CommandName New-OfficeWebAppsHost -Exactly -Times 1
                }
            }

            Context "Add new domain and remove it at the same time" {
                $testParams = @{
                    DomainsToInclude = @("oos1.contoso.com")
                    DomainsToExclude = @("oos1.contoso.com")
                    IsSingleInstance = "Yes"
                }

                Mock -CommandName Get-OfficeWebAppsHost -MockWith {
                    $instance = [PSCustomObject] @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    return $instance
                }

                It "Throws an exception from 'Test-TargetResource'" {
                    { Test-TargetResource $testParams } | Should throw
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}

