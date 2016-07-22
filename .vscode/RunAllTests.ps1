Import-Module (Join-Path $PSScriptRoot "..\Tests\Unit\OfficeOnlineServerDsc.TestHarness.psm1"  -Resolve) -Force

$DscTestsPath = Join-Path $PSScriptRoot "..\Modules\OfficeOnlineServerDsc\DscResource.Tests" -Resolve
if ((Test-Path $DscTestsPath) -eq $false) {
    Write-Warning "Unable to locate DscResource.Tests repo at '$DscTestsPath', common DSC resource tests will not be executed"
    Invoke-OosDscUnitTestSuite -CalculateTestCoverage $false
} else {
    Invoke-OosDscUnitTestSuite -DscTestsPath $DscTestsPath -CalculateTestCoverage $false
}

