$Global:DSCModuleName      = 'xOfficeOnlineServer'
$Global:DSCResourceName    = 'MSFT_xOfficeOnlineServerWebAppsMachine'

#region HEADER
# Unit Test Template Version 1.1.0
[String] $moduleRoot = Join-Path -Path $PSScriptRoot -ChildPath "..\..\Modules\xOfficeOnlineServer" -Resolve
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
#endregion HEADER

# Begin Testing
try
{
    InModuleScope $Global:DSCResourceName {
        #region Pester Test Initialization

        function Remove-OfficeWebAppsMachine  {}
        function New-OfficeWebAppsMachine {}
        function Get-OfficeWebAppsMachine {}

        #endregion Pester Test Initialization

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)Get-TargetResource" {
            It "Should throw when module is not found" {
                Mock -CommandName Import-Module -MockWith { Throw "Failed to import module" }

                { Get-TargetResource -MachineToJoin $env:COMPUTERNAME } | should throw "Failed to import module"

            }

            It "Should return absent if Web Apps Machine is not found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-OfficeWebAppsMachine -MockWith { throw "It does not appear that this machine is part of an Office Online Server farm." }

                $results = Get-TargetResource -MachineToJoin $env:COMPUTERNAME

                $results.Ensure | should be 'Absent'
                $results.Roles | should be ''
                $results.MachineToJoin | should be ''
            }

            It "Should return present if Web Apps Machine is found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-OfficeWebAppsMachine -MockWith { @{ Roles = "all"; MasterMachineName = "Machine1"} }

                $results = Get-TargetResource -MachineToJoin $env:COMPUTERNAME

                $results.Ensure | should be 'Present'
                $results.Roles | should be 'all'
                $results.MachineToJoin | should be 'Machine1'
            }

            It "Should throw if Get-OfficeWebAppsMachine throws an error other then server not foud" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-OfficeWebAppsMachine -MockWith { throw "Unexpected error" }

                { Get-TargetResource -MachineToJoin $env:COMPUTERNAME } | should throw "Unexpected error"
            }
        }
        #endregion Function Get-TargetResource


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)Test-TargetResource" {
            It "Should return true when ensure is present and all properties match" {
                Mock -CommandName Get-TargetResource -MockWith { @{ Ensure = "Present"; Roles = "All"; MachineToJoin = $env:COMPUTERNAME } }

                $result = Test-TargetResource -Ensure "Present" -MachineToJoin $env:COMPUTERNAME

                $result | should be $true
            }

            It "Should return false when ensure is present and machine to join does not match" {
                Mock -CommandName Get-TargetResource -MockWith { @{ Ensure = "Present"; Roles = "All"; MachineToJoin = $env:COMPUTERNAME } }

                $result = Test-TargetResource -Ensure "Present" -MachineToJoin "NotThisMachine"

                $result | should be $false
            }

            It "Should return false when ensure is present and roles does not match" {
                Mock -CommandName Get-TargetResource -MockWith { @{ Ensure = "Present"; Roles = "All"; MachineToJoin = $env:COMPUTERNAME } }

                $result = Test-TargetResource -Ensure "Present" -MachineToJoin $env:COMPUTERNAME -Roles "FrontEnd"

                $result | should be $false
            }

            It "Should return false when ensure is present and roles and machine to join does not match" {
                Mock -CommandName Get-TargetResource -MockWith { @{ Ensure = "Present"; Roles = "All"; MachineToJoin = $env:COMPUTERNAME } }

                $result = Test-TargetResource -Ensure "Present" -MachineToJoin $env:COMPUTERNAME -Roles "NotThisMachine"

                $result | should be $false
            }

            It "Should return true when ensure is absent" {
                Mock -CommandName Get-TargetResource -MockWith { @{ Ensure = "Absent"; Roles = ""; MachineToJoin = "" } }

                $result = Test-TargetResource -Ensure "Absent" -MachineToJoin $env:COMPUTERNAME

                $result | should be $true
            }

            It "Should return false when ensure does not match" {
                Mock -CommandName Get-TargetResource -MockWith { @{ Ensure = "Absent"; Roles = ""; MachineToJoin = "" } }

                $result = Test-TargetResource -Ensure "Present" -MachineToJoin $env:COMPUTERNAME

                $result | should be $false
            }
        }
        #endregion Function Test-TargetResource


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)Set-TargetResource" {
            It "Should throw when module is not found" {
                Mock -CommandName Import-Module -MockWith { Throw "Failed to import module" }

                { Set-TargetResource -Ensure "Absent" -MachineToJoin $env:COMPUTERNAME } | should throw "Failed to import module"

            }

            It "Should remove the Web Apps Machine when ensure is set to absent" {
                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {} -Verifiable
                Mock -CommandName Import-Module -MockWith {}

                Set-TargetResource -Ensure "Absent" -MachineToJoin $env:COMPUTERNAME

                Assert-MockCalled -CommandName Remove-OfficeWebAppsMachine -Times 1
            }

            It "Should throw if it fails to remove the Web Apps Machine" {
                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith { throw "I failed" } 
                Mock -CommandName Import-Module -MockWith {}

                { Set-TargetResource -Ensure "Absent" -MachineToJoin $env:COMPUTERNAME } | should throw "I failed"
            }

            It "Should attempt to remove the Web Apps Machine when ensure is set to present" {
                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {} -Verifiable
                Mock -CommandName Import-Module -MockWith {}

                Set-TargetResource -Ensure "Present" -MachineToJoin $env:COMPUTERNAME

                Assert-MockCalled -CommandName Remove-OfficeWebAppsMachine -Times 1
            }

            It "Should not throw if removing the Web Apps Machine fails when ensure is set to present" {
                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith { throw "I failed" } 
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName New-OfficeWebAppsMachine -MockWith {} -Verifiable

                $results = $null
                $results = Set-TargetResource -Ensure "Present" -MachineToJoin $env:COMPUTERNAME

                Assert-MockCalled -CommandName New-OfficeWebAppsMachine -Times 1
                $results | should be $null
            }

            It "Should add a new Web App Machine when ensure is set to present" {
                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {} 
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName New-OfficeWebAppsMachine -MockWith {} -Verifiable

                $results = $null
                $results = Set-TargetResource -Ensure "Present" -MachineToJoin $env:COMPUTERNAME

                Assert-MockCalled -CommandName New-OfficeWebAppsMachine -Times 1
                $results | should be $null
            }

            It "Should throw if it fails to add a nwe Web App Machine when ensure is set to present" {
                Mock -CommandName Remove-OfficeWebAppsMachine -MockWith {} 
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName New-OfficeWebAppsMachine -MockWith { throw "I failed" } -Verifiable

                { Set-TargetResource -Ensure "Present" -MachineToJoin $env:COMPUTERNAME } | should throw "I failed"
            }
        }
        #endregion Function Set-TargetResource

        #endregion Exported Function Unit Tests
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}

