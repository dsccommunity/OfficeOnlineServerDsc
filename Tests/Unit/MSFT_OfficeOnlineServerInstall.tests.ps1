[CmdletBinding()]
param(
    [string] $WACCmdletModule = (Join-Path $PSScriptRoot "\Stubs\Office15.WACServer\OfficeWebApps.psm1" -Resolve)
)

$Global:DSCModuleName      = 'xOfficeOnlineServer'
$Global:DSCResourceName    = 'MSFT_OfficeOnlineServerInstall'
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
        Describe "xOfficeOnlineServerInstall [Simulating $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {

            Import-Module (Join-Path $PSScriptRoot "..\..\Modules\OfficeOnlineServerDsc" -Resolve)
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue 

            Context "Office online server is not installed, but should be" {
                $testParams = @{
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

                it "returns that it is not installed from the get method" {
                    (Get-TargetResource @testParams).Installed | Should Be $false
                }

                it "returns false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                it "starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                }
            }

            Context "Office online server 2016 is installed and should be" {
                $testParams = @{
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock Get-ChildItem -MockWith {
                    return @(
                        @{
                            Name = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office16.WacServer"
                        }
                    )
                }

                it "returns that it is installed from the get method" {
                    (Get-TargetResource @testParams).Installed | Should Be $true
                }

                it "returns true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }

            Context "Office Web Apps 2013 is installed and should be" {
                $testParams = @{
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock Get-ChildItem -MockWith {
                    return @(
                        @{
                            Name = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office15.WacServer"
                        }
                    )
                }

                it "returns that it is installed from the get method" {
                    (Get-TargetResource @testParams).Installed | Should Be $true
                }

                it "returns true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }

            Context "Office online server is not installed, but should be" {
                $testParams = @{
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

                it "starts the install from the set method" {
                    { Set-TargetResource @testParams } | Should Throw
                }
            }
        }
    }
}
catch
{
    $_
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
