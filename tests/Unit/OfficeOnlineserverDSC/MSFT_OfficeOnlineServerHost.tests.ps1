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

                It "Throws an exception from the get method" {
                    { Get-TargetResource $testParams } | Should throw
                }

                It "Throws an exception from the test method" {
                    { Test-TargetResource $testParams } | Should throw
                }

                It "Throws an exception from the set method" {
                    { Set-TargetResource $testParams } | Should throw
                }
            }

            Context "Add new domain to an empty allowlist" {
                $testParams = @{
                    AllowList        = "oos1.contoso.com"
                    IsSingleInstance = "Yes"
                }

                Mock -CommandName Get-OfficeWebAppsHost -MockWith {
                    $OfficeWebAppsHostObject = New-Object -TypeName PSCustomObject -Property @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    return $OfficeWebAppsHostObject
                }

                It "Should return 'Absent' from 'Get-TargetResource'" {
                    (Get-TargetResource @testParams).Ensure | Should Be 'Absent'
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
                    $OfficeWebAppsHostObject = New-Object -TypeName PSCustomObject -Property @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    $OfficeWebAppsHostObject.allowList.Add("oos1.contoso.com")
                    return $OfficeWebAppsHostObject
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
                    $OfficeWebAppsHostObject = New-Object -TypeName PSCustomObject -Property @{
                        allowList = [System.Collections.Generic.List`1[[System.String, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]]]::new()
                    }
                    $OfficeWebAppsHostObject.allowList.Add("oos1.contoso.com")
                    return $OfficeWebAppsHostObject
                }

                It "Should return allowlist containing exisiting domain from 'Get-TargetResource'" {
                    (Get-TargetResource @testParams).AllowList | Should Be @("oos1.contoso.com")
                }

                It "Should return 'False' from 'Test-TargetResource'" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "Should call 'Remove-OfficeWebAppsHost' within 'Set-TargetResource'" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName Remove-OfficeWebAppsHost
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}

