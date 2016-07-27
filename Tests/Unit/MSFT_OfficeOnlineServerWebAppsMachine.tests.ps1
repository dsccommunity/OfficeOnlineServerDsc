[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$Script:DSCModuleName      = 'OfficeOnlineServerDsc'
$Script:DSCResourceName    = 'MSFT_OfficeOnlineServerWebAppsMachine'
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

        Describe "OfficeOnlineServerWebAppsFarm [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {
            
            Import-Module (Join-Path $PSScriptRoot "..\..\Modules\OfficeOnlineServerDsc" -Resolve)
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue 

            Mock -CommandName New-OfficeWebAppsMachine -MockWith {}
            Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {}

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
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

