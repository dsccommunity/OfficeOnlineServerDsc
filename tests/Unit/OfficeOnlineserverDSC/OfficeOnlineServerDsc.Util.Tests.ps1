[CmdletBinding()]
param(
    [String] $WACCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\15.0.4569.1506\OfficeWebApps.psm1" -Resolve)
)

$Global:CurrentWACCmdletModule = $WACCmdletModule

$script:projectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$script:projectName = (Get-ChildItem -Path "$script:projectPath\*\*.psd1" | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest -Path $_.FullName -ErrorAction Stop } catch { $false })
    }).BaseName

$script:parentModule = Get-Module -Name $script:projectName -ListAvailable | Select-Object -First 1
$script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'
Remove-Module -Name $script:parentModule -Force -ErrorAction 'SilentlyContinue'

$script:subModuleName = (Split-Path -Path $PSCommandPath -Leaf) -replace '\.Tests.ps1'
$script:subModuleFile = Join-Path -Path $script:subModulesFolder -ChildPath "$($script:subModuleName)"

Import-Module $script:subModuleFile -Force -ErrorAction Stop

#Import-Module (Join-Path $PSScriptRoot "..\..\..\Modules\OfficeOnlineServerDsc\Modules\OfficeOnlineServerDsc.Util\OfficeOnlineServerDsc.Util.psm1" -Resolve)

InModuleScope "OfficeOnlineServerDsc.Util" {
    Describe "OfficeOnlineServerDsc.Util tests [WAC server version $((Get-Item $Global:CurrentWACCmdletModule).Directory.BaseName)]" {

        Remove-Module -Name "OfficeWebApps" -Force -ErrorAction SilentlyContinue
        Import-Module $Global:CurrentWACCmdletModule -WarningAction SilentlyContinue

        Context "Validate Test-OosDscParameterState" {
            It "Returns true for two identical tables" {
                $desired = @{ Example = "test" }
                Test-OosDscParameterState -CurrentValues $desired -DesiredValues $desired | Should Be $true
            }

            It "Returns false when a value is different" {
                $current = @{ Example = "something" }
                $desired = @{ Example = "test" }
                Test-OosDscParameterState -CurrentValues $current -DesiredValues $desired | Should Be $false
            }

            It "Returns false when a value is missing" {
                $current = @{ }
                $desired = @{ Example = "test" }
                Test-OosDscParameterState -CurrentValues $current -DesiredValues $desired | Should Be $false
            }

            It "Returns true when only a specified value matches, but other non-listed values do not" {
                $current = @{ Example = "test"; SecondExample = "true" }
                $desired = @{ Example = "test"; SecondExample = "false"  }
                Test-OosDscParameterState -CurrentValues $current -DesiredValues $desired -ValuesToCheck @("Example") | Should Be $true
            }

            It "Returns false when only specified values do not match, but other non-listed values do " {
                $current = @{ Example = "test"; SecondExample = "true" }
                $desired = @{ Example = "test"; SecondExample = "false"  }
                Test-OosDscParameterState -CurrentValues $current -DesiredValues $desired -ValuesToCheck @("SecondExample") | Should Be $false
            }

            It "Returns false when an empty array is used in the current values" {
                $current = @{ }
                $desired = @{ Example = "test"; SecondExample = "false"  }
                Test-OosDscParameterState -CurrentValues $current -DesiredValues $desired | Should Be $false
            }
        }
    }
}