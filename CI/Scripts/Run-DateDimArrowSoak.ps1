<#
.SYNOPSIS
    Runs repeated DateDim Arrow regression tests to catch intermittent parser failures.

.DESCRIPTION
    Executes focused test files in a loop and inspects output text for pass/fail markers.
    This script is intended for local and agent-driven validation of intermittent
    ExecuteDaxQueriesInGroup Arrow parsing failures.

.PARAMETER Iterations
    Number of repeated test runs. Default is 5.

.PARAMETER CompileFirstRun
    When true, compiles on iteration 1 and uses -Compile $false for remaining iterations.

.PARAMETER TestFileName
    Optional test file names. Defaults include DateDim parity and connector proof tests.

.EXAMPLE
    .\CI\Scripts\Run-DateDimArrowSoak.ps1

.EXAMPLE
    .\CI\Scripts\Run-DateDimArrowSoak.ps1 -Iterations 10
#>
param(
    [ValidateRange(1, 100)]
    [int]$Iterations = 5,
    [bool]$CompileFirstRun = $true,
    [string[]]$TestFileName = @(
        "PBIRESTAPIComm.tests.datasets.parity.query.pq",
        "PBIRESTAPIComm.tests.connector.proof.query.pq"
    )
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\.." )).Path
$RunScript = Join-Path $RepoRoot "CI\Scripts\Run-PQTests.ps1"

if(-not (Test-Path -Path $RunScript)){
    Write-Error "Required test script not found: $RunScript"
    exit 1
}

$ArtifactsDir = Join-Path $RepoRoot "artifacts\arrow-soak"
if(-not (Test-Path -Path $ArtifactsDir)){
    New-Item -Path $ArtifactsDir -ItemType Directory | Out-Null
}

$SessionStamp = Get-Date -Format "yyyyMMdd-HHmmss"
$Summary = @()

Write-Host "Arrow soak start: iterations=$Iterations"
Write-Host "Test files: $($TestFileName -join ', ')"

for($i = 1; $i -le $Iterations; $i++){
    $compileThisRun = if($CompileFirstRun -and $i -eq 1) { $true } else { $false }
    $logPath = Join-Path $ArtifactsDir ("arrow-soak-{0}-iter-{1:D2}.log" -f $SessionStamp, $i)

    Write-Host ""
    Write-Host ("[{0}/{1}] Running tests (Compile={2})" -f $i, $Iterations, $compileThisRun)

    $runOutput = & $RunScript -Compile $compileThisRun -TestFileName $TestFileName *>&1
    $runOutput | Out-File -FilePath $logPath -Encoding utf8

    $text = ($runOutput | Out-String)
    $hasPassMarker = $text -match "All split test files passed"
    $hasFailMarker = $text -match "\[FAIL\]|One or more test files failed"
    $passed = $hasPassMarker -and (-not $hasFailMarker)

    $Summary += [PSCustomObject]@{
        Iteration = $i
        Compile = $compileThisRun
        Passed = $passed
        Log = $logPath
    }

    if($passed){
        Write-Host ("[{0}/{1}] PASS" -f $i, $Iterations)
    }
    else{
        Write-Error ("[{0}/{1}] FAIL - see log: {2}" -f $i, $Iterations, $logPath)
        $Summary | Format-Table -AutoSize
        exit 1
    }
}

Write-Host ""
Write-Host "Arrow soak summary:"
$Summary | Format-Table -AutoSize
Write-Host "All soak iterations passed"
exit 0
