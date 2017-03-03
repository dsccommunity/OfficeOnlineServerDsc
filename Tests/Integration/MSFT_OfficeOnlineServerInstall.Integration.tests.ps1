$Script:DSCModuleName      = 'OfficeOnlineServerDsc'
$Script:DSCResourceName    = 'MSFT_OfficeOnlineServerInstall' 

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
    -DSCModuleName $Script:DSCModuleName `
    -DSCResourceName $Script:DSCResourceName `
    -TestType Integration 

try
{
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

    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($Script:DSCResourceName)_Integration" {
        $uninstallKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office16.WacServer'
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($Script:DSCResourceName)_Config -OutputPath `$TestEnvironment.WorkingFolder"
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                    -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $wacRegPathExist = Test-Path -Path $uninstallKey
            $wacRegPathExist | Should Be $true
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
