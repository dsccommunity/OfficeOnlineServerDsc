[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$script:DSCModuleName = 'OfficeOnlineServerDsc'
$script:DSCResourceName = 'MSFT_OfficeOnlineServerInstall'
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
        Describe "OfficeOnlineServerInstall [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue

            Context "Office online server is not installed, but should be" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.Path }

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

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.Path }

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

            Context "Office online server is not installed, but should be" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.Path }

                Mock -CommandName Get-ChildItem -MockWith {
                    return @()
                }
                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 3010
                    }
                }

                It "Starts the install from the set method and initiates reboot" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                    $global:DscMachineStatus | Should Be 1
                }
            }

            Context "Office Web Apps 2013 is installed and should be" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.Path }

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

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.Path }

                Mock -CommandName Get-ChildItem -MockWith {
                    return @()
                }
                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 0
                    }
                }

                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                }
            }

            Context "Office online server is not installed, but should be and using UNC path" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "\\server\InstallFiles\setup.exe"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.Path }

                Mock -CommandName Get-Item -MockWith {
                    return $null
                }

                Mock -CommandName Get-ChildItem -MockWith {
                    return @()
                }
                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 0
                    }
                }

                It "Starts the install from the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Start-Process
                }
            }

            Context "Setup file does not exist" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq $testParams.Path }

                It "Throws exception in the get method" {
                    { Get-TargetResource @testParams } | Should Throw "Specified path cannot be found."
                }

                It "Throws exception in the set method" {
                    { Set-TargetResource @testParams } | Should Throw "Specified path cannot be found."
                }

                It "Throws exception in the test method" {
                    { Set-TargetResource @testParams } | Should Throw "Specified path cannot be found."
                }
            }

            Context "Setup file is blocked" {
                $testParams = @{
                    Ensure = "Present"
                    Path = "C:\InstallFiles\setup.exe"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.Path }

                Mock -CommandName Get-Item -MockWith {
                    return "data"
                }

                It "Throws exception in the get method" {
                    { Get-TargetResource @testParams } | Should Throw "Setup file is blocked!"
                }

                It "Throws exception in the set method" {
                    { Set-TargetResource @testParams } | Should Throw "Setup file is blocked!"
                }

                It "Throws exception in the test method" {
                    { Set-TargetResource @testParams } | Should Throw "Setup file is blocked!"
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
