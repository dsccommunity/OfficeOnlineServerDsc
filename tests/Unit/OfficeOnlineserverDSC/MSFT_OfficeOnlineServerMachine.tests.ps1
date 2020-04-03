[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$script:DSCModuleName = 'OfficeOnlineServerDsc'
$script:DSCResourceName = 'MSFT_OfficeOnlineServerMachine'
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
        -DSCResourceName $script:dscResourceName `
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
        Describe "OfficeOnlineServerMachine [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue

            Mock -CommandName New-OfficeWebAppsMachine -MockWith {}
            Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {}
            Mock -CommandName Test-Path -MockWith {
                return $false
            } -ParameterFilter { $_.Path -eq 'HKLM:\SOFTWARE\OOSDsc' }

            Context "The Office Online Server PowerShell module can not be found" {
                $testParams = @{
                    MachineToJoin = "oos1.contoso.com"
                }

                Mock -CommandName Import-Module -MockWith {
                    throw "Failed to import module"
                } -ParameterFilter {
                    $Name -eq "OfficeWebApps"
                }

                It "Throws an exception from the get method" {
                    { Get-TargetResource $testParams } | should throw
                }

                It "Throws an exception from the test method" {
                    { Test-TargetResource $testParams } | should throw
                }

                It "Throws an exception from the set method" {
                    { Set-TargetResource $testParams } | should throw
                }
            }

            Mock -CommandName Import-Module -MockWith { } -ParameterFilter {
                $Name -eq "OfficeWebApps"
            }

            Context "The local server is not connect to a farm, but should be" {
                $testParams = @{
                    MachineToJoin = "oos1.contoso.com"
                }

                Mock -CommandName Get-OfficeWebAppsMachine -MockWith {
                    throw "It does not appear that this machine is part of an Office Online Server farm."
                }

                It "Should return absent from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "Should return false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "Should join the server to the farm in the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName New-OfficeWebAppsMachine
                }
            }

            Context "The local server is connected to a farm and should be" {
                $testParams = @{
                    MachineToJoin = "oos1.contoso.com"
                }

                Mock -CommandName Get-OfficeWebAppsMachine -MockWith {
                    @{
                        Roles = "all";
                        MasterMachineName = $testParams.MachineToJoin
                    }
                }

                It "Should return present from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Should return true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }

            Context "The local server is connected to a farm, but the roles are incorrect" {
                $testParams = @{
                    MachineToJoin = "oos1.contoso.com"
                }

                Mock -CommandName Get-OfficeWebAppsMachine -MockWith {
                    @{
                        Roles = "FrontEnd";
                        MasterMachineName = $testParams.MachineToJoin
                    }
                }

                It "Should return present from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Should return false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "Should join the server to the farm in the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName New-OfficeWebAppsMachine
                    Assert-MockCalled -CommandName Remove-OfficeWebAppsMachine
                }
            }

            Context "The local server is connected to to a farm, but it should not be" {
                $testParams = @{
                    MachineToJoin = "oos1.contoso.com"
                    Ensure = "Absent"
                }

                Mock -CommandName Get-OfficeWebAppsMachine -MockWith {
                    @{
                        Roles = "all";
                        MasterMachineName = $testParams.MachineToJoin
                    }
                }

                It "Should return present from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Should return false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "Should join the server to the farm in the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled -CommandName Remove-OfficeWebAppsMachine
                }
            }

            Context "The local server is not connected to a farm and should not be" {
                $testParams = @{
                    MachineToJoin = "oos1.contoso.com"
                    Ensure = "Absent"
                }

                Mock -CommandName Get-OfficeWebAppsMachine -MockWith {
                    throw "It does not appear that this machine is part of an Office Online Server farm."
                }

                It "Should return absent from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "Should return true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }

            Context "Server is returning after a reboot after patching, do nothing" {
                $testParams = @{
                    MachineToJoin = "oos1.contoso.com"
                    Ensure = "Absent"
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

