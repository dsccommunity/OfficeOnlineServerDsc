<#
.Synopsis
   Template for creating DSC Resource Integration Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Integration\ folder and rename <ResourceName>.Integration.tests.ps1 (e.g. MSFT_xNeworking.Integration.tests.ps1)
     2. Customize TODO sections.
     3. Create test DSC Configurtion file <ResourceName>.config.ps1 (e.g. MSFT_xNeworking.config.ps1) from integration_config_template.ps1 file.

.NOTES
   Code in HEADER, FOOTER and DEFAULT TEST regions are standard and may be moved into
   DSCResource.Tools in Future and therefore should not be altered if possible.
#>

# TODO: Customize these parameters...
$Global:DSCModuleName      = 'OfficeOnlineServerDsc' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_OfficeOnlineServerInstall' # Example MSFT_xFirewall
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
    -TestType Integration 
#endregion

#Ensure required Windows features are installed

$webServerInstalled = (Get-WindowsFeature -Name Web-Server).Installed
$aspDotNET45 = (Get-WindowsFeature -Name 'Web-Asp-Net45').Installed
Describe 'Environment' {
    Context 'Windows Features' {

        It 'Should have Web-Server installed' {
            $webServerInstalled | Should Be $true
        }

        It 'Should have Web-Asp-Net45 installed' {
            $aspDotNET45 | Should Be $true
        }
    }
}

if($webServerInstalled -eq $false -or $aspDotNET45 -eq $false)
{
    break
}

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Global:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($Global:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        $uninstallKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office16.WacServer'
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($Global:DSCResourceName)_Config -OutputPath `$TestEnvironment.WorkingFolder"
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                    -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            $wacRegPathExist = Test-Path -Path $uninstallKey
            $wacRegPathExist | Should Be $true
        }
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
