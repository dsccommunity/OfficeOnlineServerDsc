$Script:DSCModuleName      = 'OfficeOnlineServerDsc' 
$Script:DSCResourceName    = 'MSFT_OfficeOnlineServerWebAppsFarm' 

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
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($Script:DSCResourceName)_Integration" {
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

            $result = Get-OfficeWebAppsFarm

            foreach($key in $webAppsFarm.keys)
            {
                $result.$key | Should Be $webAppsFarm[$key]
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
