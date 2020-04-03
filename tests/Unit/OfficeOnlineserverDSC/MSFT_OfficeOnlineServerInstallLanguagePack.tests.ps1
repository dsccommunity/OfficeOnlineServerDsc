[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$script:DSCModuleName = 'OfficeOnlineServerDsc'
$script:DSCResourceName = 'MSFT_OfficeOnlineServerInstallLanguagePack'
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
        Describe "OfficeOnlineServerInstallLanguagePack [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {
            Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
            Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue

            Context "Office Online Server 2016 is not installed but should be" {
                $testParams = @{
                    Ensure = "Present"
                    Language = "fr-fr"
                    BinaryDir= "C:\LanguagePack"
                }

                Mock -CommandName Get-ChildItem -MockWith {
                    return @()
                }
                Mock -CommandName Start-Process -MockWith {
                    return @{
                        ExitCode = 0
                    }
                }
                Mock -CommandName Test-Path -MockWith{
                    return $true
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

            Context "Office Online Server 2016 is installed and should be" {
                $testParams = @{
                    Ensure = "Present"
                    Language = "fr-fr"
                    BinaryDir = "C:\LanguagePack"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.BinaryDir }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq (Join-Path -Path $testParams.BinaryDir -ChildPath "setup.exe") }

                Mock Get-ChildItem -MockWith {
                    return @(
                        @{
                            Name = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office16.WacServerLpk.fr-fr"
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

            Context "Office Web Apps 2013 French Language Pack is installed and should be" {
                $testParams = @{
                    Ensure = "Present"
                    BinaryDir= "C:\LanguagePack"
                    Language = "fr-fr"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.BinaryDir }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq (Join-Path -Path $testParams.BinaryDir -ChildPath "setup.exe") }

                Mock Get-ChildItem -MockWith {
                    return @(
                        @{
                            Name = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office15.WacServerLpk.fr-fr"
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

            Context "Office Online Server French Language Pack is not installed, but should be" {
                $testParams = @{
                    Ensure = "Present"
                    Language = "fr-fr"
                    BinaryDir= "C:\LanguagePack"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.BinaryDir }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq (Join-Path -Path $testParams.BinaryDir -ChildPath "setup.exe") }

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

            Context "Office Online Server French Language Pack is not installed, but should be using UNC path" {
                $testParams = @{
                    Ensure = "Present"
                    Language = "fr-fr"
                    BinaryDir= "\\server\Install\LanguagePack"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.BinaryDir }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq (Join-Path -Path $testParams.BinaryDir -ChildPath "setup.exe") }

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

            Context "BinaryDir does not exist" {
                $testParams = @{
                    Ensure = "Present"
                    Language = "fr-fr"
                    BinaryDir= "C:\LanguagePack"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq $testParams.BinaryDir }

                It "Should throw exception in the get method" {
                    { Get-TargetResource @testParams } | Should Throw "Specified path cannot be found."
                }

                It "Should throw exception in the set method" {
                    { Set-TargetResource @testParams } | Should Throw "Specified path cannot be found."
                }

                It "Should throw exception in the test method" {
                    { Test-TargetResource @testParams } | Should Throw "Specified path cannot be found."
                }
            }

            Context "Setup.exe does not exist in BinaryDir" {
                $testParams = @{
                    Ensure = "Present"
                    Language = "fr-fr"
                    BinaryDir= "C:\LanguagePack"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.BinaryDir }

                Mock -CommandName Test-Path -MockWith {
                    return $false
                } -ParameterFilter { $Path -eq (Join-Path -Path $testParams.BinaryDir -ChildPath "setup.exe") }

                It "Should throw exception in the get method" {
                    { Get-TargetResource @testParams } | Should Throw "Setup.exe cannot be found"
                }

                It "Should throw exception in the set method" {
                    { Set-TargetResource @testParams } | Should Throw "Setup.exe cannot be found"
                }

                It "Should throw exception in the test method" {
                    { Test-TargetResource @testParams } | Should Throw "Setup.exe cannot be found"
                }
            }

            Context "Setup.exe file is blocked" {
                $testParams = @{
                    Ensure = "Present"
                    Language = "fr-fr"
                    BinaryDir= "C:\LanguagePack"
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq $testParams.BinaryDir }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ParameterFilter { $Path -eq (Join-Path -Path $testParams.BinaryDir -ChildPath "setup.exe") }

                Mock -CommandName Get-Item -MockWith {
                    return "data"
                }

                It "Should throw exception in the get method" {
                    { Get-TargetResource @testParams } | Should Throw "Setup file is blocked!"
                }

                It "Should throw exception in the set method" {
                    { Set-TargetResource @testParams } | Should Throw "Setup file is blocked!"
                }

                It "Should throw exception in the test method" {
                    { Test-TargetResource @testParams } | Should Throw "Setup file is blocked!"
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
