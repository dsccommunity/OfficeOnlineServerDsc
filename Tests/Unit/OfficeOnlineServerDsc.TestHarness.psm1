function Invoke-xOosUnitTestSuite() {
    param
    (
        [parameter(Mandatory = $false)] [System.String]  $testResultsFile,
        [parameter(Mandatory = $false)] [System.String]  $DscTestsPath,
        [parameter(Mandatory = $false)] [System.Boolean] $CalculateTestCoverage = $true
    )

    Write-Verbose -Message "Commencing OfficeOnlineServerDsc unit tests"

    $repoDir = Join-Path $PSScriptRoot "..\..\" -Resolve

    $testCoverageFiles = @()
    if ($CalculateTestCoverage -eq $true) {
        Write-Warning -Message ("Code coverage statistics are being calculated. This will slow the " + `
                                "start of the tests by several minutes while the code matrix is " + `
                                "built. Please be patient")
        Get-ChildItem "$repoDir\modules\OfficeOnlineServerDsc\**\*.psm1" -Recurse | ForEach-Object { 
            if ($_.FullName -notlike "*\DSCResource.Tests\*") {
                $testCoverageFiles += $_.FullName    
            }
        }    
    }
    

    $testResultSettings = @{ }
    if ([string]::IsNullOrEmpty($testResultsFile) -eq $false) {
        $testResultSettings.Add("OutputFormat", "NUnitXml" )
        $testResultSettings.Add("OutputFile", $testResultsFile)
    }
    Import-Module "$repoDir\modules\OfficeOnlineServerDsc\OfficeOnlineServerDsc.psd1"
    
    
    $versionsToTest = (Get-ChildItem (Join-Path $repoDir "\Tests\Unit\Stubs\")).Name
    
    # Import the first stub found so that there is a base module loaded before the tests start
    $firstVersion = $versionsToTest | Select -First 1
    Import-Module (Join-Path $repoDir "\Tests\Unit\Stubs\$firstVersion\OfficeWebApps.psm1") -WarningAction SilentlyContinue

    $testsToRun = @()
    $versionsToTest | ForEach-Object {
        $testsToRun += @(@{
            'Path' = (Join-Path -Path $repoDir -ChildPath "\Tests\Unit")
            'Parameters' = @{ 
                'SharePointCmdletModule' = (Join-Path $repoDir "\Tests\Unit\Stubs\$_\OfficeWebApps.psm1")
            }
        })
    }
    
    if ($PSBoundParameters.ContainsKey("DscTestsPath") -eq $true) {
        $testsToRun += @{
            'Path' = $DscTestsPath
            'Parameters' = @{ }
        }
    }
    $Global:VerbosePreference = "SilentlyContinue"
    $results = Invoke-Pester -Script $testsToRun -CodeCoverage $testCoverageFiles -PassThru @testResultSettings

    return $results
}
