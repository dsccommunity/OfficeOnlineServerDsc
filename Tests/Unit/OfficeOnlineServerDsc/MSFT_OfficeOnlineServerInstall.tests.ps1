[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$Script:DSCModuleName      = 'OfficeOnlineServerDsc'
$Script:DSCResourceName    = 'MSFT_OfficeOnlineServerInstall'
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
        Describe "OfficeOnlineServerInstall [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {

            Import-Module (Join-Path $PSScriptRoot "..\..\Modules\OfficeOnlineServerDsc" -Resolve)
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue 

            Context "Office online server is not installed, but should be" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock -CommandName Get-ChildItem -MockWith {
                    return @()
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

                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                }
            }

            Context "Office online server 2016 is installed and should be" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock Get-ChildItem -MockWith {
                    return @(
                        @{
                            Name = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office16.WacServer"
                        }
                    )
                }

                It "Returns that it is installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Returns true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }

            Context "Office Web Apps 2013 is installed and should be" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock Get-ChildItem -MockWith {
                    return @(
                        @{
                            Name = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office15.WacServer"
                        }
                    )
                }

                It "Returns that it is installed from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "Returns true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }

            Context "Office online server is not installed, but should be" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock -CommandName Get-ChildItem -MockWith {
                    return @()
                }
                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 1001
                    }
                }

                It "Starts the install from the set method" {
                    { Set-TargetResource @testParams } | Should Throw
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
