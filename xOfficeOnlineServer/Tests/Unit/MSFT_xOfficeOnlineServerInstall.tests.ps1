<#
.Synopsis
   Template for creating DSC Resource Unit Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Unit\ folder and rename <ResourceName>.tests.ps1 (e.g. MSFT_xFirewall.tests.ps1)
     2. Customize TODO sections.

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>


# TODO: Customize these parameters...
$Global:DSCModuleName      = 'xOfficeOnlineServer'
$Global:DSCResourceName    = 'MSFT_xOfficeOnlineServerInstall'
# /TODO

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# TODO: Other Optional Init Code Goes Here...

# Begin Testing
try
{

    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        # TODO: Optopnal Load Mock for use in Pester tests here...
        #endregion

		#test parameters
		$installPath = 'C:\InstallFiles\setup.exe'

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            Context 'Office Online Server is not installed' {
				Mock Test-Path -MockWith {$false}

				It 'Installed should be FALSE' {
					$Result = Get-TargetResource -Path $installPath
					$Result.Installed | Should Be $false
				}

				It 'Should call expected mocks' {
					Assert-MockCalled -CommandName Test-Path -Exactly 1
				}
			}

			Context 'Office Online Server is installed' {
				Mock Test-Path -MockWith {$true}

				It 'Installed should be TRUE' {
					$Result = Get-TargetResource -Path $installPath
					$Result.Installed | Should Be $true
				}

				It 'Should call expected mocks' {
					Assert-MockCalled -CommandName Test-Path -Exactly 1
				}				
			}
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'Testing when Office Online Server is installed' {
                Mock Test-Path -MockWith {$true}

                It 'Should return TRUE as if installed' {
                    {
                        $result = Test-TargetResource -Path $installPath
                        $result | Should Be $true
                    } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled Test-Path -Exactly 1    
                }

            }

            Context 'Testing when Office Online Server is not installed' {
                Mock Test-Path -MockWith {$false}

                It 'Should return FALSE as if not installed' {
                    {
                        $result = Test-TargetResource -Path $installPath
                        $result | Should Be $false
                    } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled Test-Path -Exactly 1    
                }
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            Context 'Testing successful installation' {

                Mock Start-Process -MockWith {}
                Mock Test-Path -MockWith {$true}

                It 'Should return TRUE as if installed successfully' {

                    {Set-TargetResource -Path $installPath} | Should Not Throw                
                }
                
                It 'Should call expected mocks' {
                    Assert-MockCalled -CommandName Start-Process -Exactly 1
                    Assert-MockCalled -CommandName Test-Path -Exactly 1
                }
            }

            Context 'Testing unsuccessful installation' {
                Mock Start-Process -MockWith {}
                Mock Test-Path -MockWith {$false}

                It 'Should throw as if installed failed' {

                    {Set-TargetResource -Path $installPath} | Should Throw                
                }
                
                It 'Should call expected mocks' {
                    Assert-MockCalled -CommandName Start-Process -Exactly 1
                    Assert-MockCalled -CommandName Test-Path -Exactly 1
                }
            }
        }
        #endregion

        # TODO: Pester Tests for any Helper Cmdlets

    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
