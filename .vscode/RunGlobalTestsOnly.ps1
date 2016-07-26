Import-Module (Join-Path $PSScriptRoot "..\Tests\Unit\OfficeOnlineServerDsc.TestHarness.psm1")

$DscTestsPath = Join-Path $PSScriptRoot "..\Modules\OfficeOnlineServerDsc\DscResource.Tests"
if ((Test-Path $DscTestsPath) -eq $false) {
    throw "Unable to locate DscResource.Tests repo at '$DscTestsPath', common DSC resource tests will not be executed"
}
Import-Module (Join-Path $PSScriptRoot "..\Modules\OfficeOnlineServerDsc\OfficeOnlineServerDsc.Tests\TestHelper.psm1")

Set-Location -Path (Join-Path $PSScriptRoot "..\Modules\OfficeOnlineServerDsc\DscResource.Tests")

Invoke-Pester 
