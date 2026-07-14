<#
Author: John Kerski
.SYNOPSIS
    This script runs the proof-of-concept Continuous Integration of a custom connector.

.DESCRIPTION
    This script runs the proof-of-concept Continuous Integration of a custom connector.

    Dependencies: Premium Per User license purchased and assigned to UserName and UserName has admin right to workspace.
.PARAMETER Compile
    Default is True, and makes sure Compile step should happen.

    Use Compile set to False when you just want to run tests.

.PARAMETER TestFileName
    Optional test file name(s) to run instead of the full suite.
    Accepts exact file names (for example PBIRESTAPIComm.tests.datasets.query.pq)
    or full relative paths from the repo root.

    Example: 
        -Compile $False

.EXAMPLE
    ./Run-PBITests.ps1
    ./Run-PBITests.ps1 -Compile $False
    ./Run-PBITests.ps1 -Compile $False -TestFileName PBIRESTAPIComm.tests.datasets.query.pq
#>
param(
    [Boolean]$Compile = $True,
    [string[]]$TestFileName,
    [ValidateSet("OAuth2", "Aad")]
    [string]$AuthenticationKind = "OAuth2"
)

function Get-TextBetweenMarkers {
    param(
        [string]$Text,
        [string]$StartMarker,
        [string]$EndMarker
    )

    $start = $Text.IndexOf($StartMarker)
    if($start -lt 0){
        return $null
    }

    $end = $Text.IndexOf($EndMarker, $start + $StartMarker.Length)
    if($end -lt 0){
        return $null
    }

    return $Text.Substring($start, ($end + $EndMarker.Length) - $start)
}

function Test-NoFallbackCallChain {
    param(
        [string]$ConnectorFilePath
    )

    if(!(Test-Path -Path $ConnectorFilePath)){
        Write-Error "No-fallback guard could not find connector source file: $ConnectorFilePath"
        return $false
    }

    $source = Get-Content -Path $ConnectorFilePath -Raw
    $forbiddenSymbols = @("ExecuteQuery", "ExecuteQueryInGroup")
    $blockSpecs = @(
        @{ Name = "ExecuteDaxQueries"; Start = "/*** ExecuteDaxQueries ***/"; End = "/*** End ExecuteDaxQueries***/" },
        @{ Name = "ExecuteDaxQueriesInGroup"; Start = "/*** ExecuteDaxQueriesInGroup ***/"; End = "/*** End ExecuteDaxQueriesInGroup***/" },
        @{ Name = "PostExecuteDax"; Start = "PostExecuteDax = (params as record) as table =>"; End = "ExecuteDaxJsonToTable = (response as binary) as table =>" },
        @{ Name = "ExecuteDaxResponseAsTable"; Start = "ExecuteDaxResponseAsTable = (response as binary, optional headers as nullable record) as table =>"; End = "ArrowDetectionContentTypes = {" }
    )

    $violations = @()
    foreach($blockSpec in $blockSpecs){
        $blockText = Get-TextBetweenMarkers -Text $source -StartMarker $blockSpec.Start -EndMarker $blockSpec.End
        if($null -eq $blockText){
            Write-Error "No-fallback guard could not locate block '$($blockSpec.Name)' using expected markers."
            return $false
        }

        foreach($symbol in $forbiddenSymbols){
            if($blockText -match ("\b" + [regex]::Escape($symbol) + "\b")){
                $violations += [PSCustomObject]@{
                    Block = $blockSpec.Name
                    Symbol = $symbol
                }
            }
        }
    }

    if($violations.Count -gt 0){
        foreach($violation in $violations){
            Write-Error "No-fallback guard violation: block '$($violation.Block)' references forbidden symbol '$($violation.Symbol)'."
        }
        return $false
    }

    Write-Host "No-fallback static guard passed: ExecuteDax call chain has no forbidden ExecuteQuery references"
    return $true
}

# Install Powershell Module if Needed
if (Get-Module -ListAvailable -Name "MicrosoftPowerBIMgmt") {
    Write-Host "MicrosoftPowerBIMgmt already installed"
} else {
    Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser -AllowClobber -Force
}

# Setup Test File Path
$RelTestFilePath = ".\\CI\\Scripts\\variables.test.json"
$RelTestTemplateFilePath = ".\\CI\\Scripts\\variables.test.template.json"

if(!(Test-Path -Path $RelTestFilePath)){
    Write-Error "Missing test variables file: $RelTestFilePath"
    Write-Error "Create it from template: Copy-Item $RelTestTemplateFilePath $RelTestFilePath"
    return 0
}

$TestFilePath = (Resolve-Path -Path $RelTestFilePath).Path

$TestVariables = Get-Content -Path $TestFilePath -Raw | ConvertFrom-Json

function Get-TestVariableValue {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Variables,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if($Variables.PSObject.Properties.Name -contains $Name){
        $value = [string]($Variables.$Name)
        if(-not [string]::IsNullOrWhiteSpace($value)){
            return $value
        }
    }

    return $null
}

$PipelineUserName = if([string]::IsNullOrWhiteSpace("${env:PPU_USERNAME}")) { $null } else { "${env:PPU_USERNAME}" }
$PipelinePassword = if([string]::IsNullOrWhiteSpace("${env:PPU_PASSWORD}")) { $null } else { "${env:PPU_PASSWORD}" }

$ConfigUserName = Get-TestVariableValue -Variables $TestVariables -Name "PPU_USERNAME"
if($null -eq $ConfigUserName){
    $ConfigUserName = Get-TestVariableValue -Variables $TestVariables -Name "UserName"
}

$ConfigPassword = Get-TestVariableValue -Variables $TestVariables -Name "PPU_PASSWORD"
if($null -eq $ConfigPassword){
    $ConfigPassword = Get-TestVariableValue -Variables $TestVariables -Name "Password"
}

$UserName = if($null -ne $PipelineUserName) { $PipelineUserName } else { $ConfigUserName }
$Password = if($null -ne $PipelinePassword) { $PipelinePassword } else { $ConfigPassword }

if(($null -ne $UserName) -and ($null -ne $Password)){
    # Connect non-interactively using credentials from pipeline env vars or local test variables.
    $Secret = $Password | ConvertTo-SecureString -AsPlainText -Force
    $Credentials = [System.Management.Automation.PSCredential]::new($UserName,$Secret)
    Connect-PowerBIServiceAccount -Credential $Credentials
}
else {
    # Fall back to interactive auth only when credentials are not configured.
    Connect-PowerBIServiceAccount
}

# Prefer the newest VS Code SDK PQTest to avoid local credential-store version drift.
$PQTestExe = ".\\CI\\PQTest\\PQTest.exe"
$SdkPQTestCandidates = @(Get-ChildItem -Path "$env:USERPROFILE\\.vscode\\extensions" -Filter "PQTest.exe" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*powerquery.vscode-powerquery-sdk*" } |
    Sort-Object LastWriteTime -Descending)

if($SdkPQTestCandidates.Count -gt 0){
    $PQTestExe = $SdkPQTestCandidates[0].FullName
    Write-Host "Using SDK PQTest: $PQTestExe"
}
else{
    Write-Host "Using bundled PQTest: $PQTestExe"
}

# Clear Credentials
$Result = $null
$Result = & $PQTestExe delete-credential --ALL

# Generate Token
$AccessToken = Get-PowerBIAccessToken
# Remove 'Bearer' from token
$AccessToken = $AccessToken.Values.Substring(7)

# Relative Extension File Path
$RelExtFilePath = ".\\bin\\AnyCPU\\Debug\\powerquery-connector-pbi-rest-api-commercial.mez"
$RelQueryCredFilePath = ".\\PBIRESTAPICommCredTemplate.query.pq"
$RelConnectorSourcePath = ".\\PBIRESTAPIComm.pq"
$RelQueryFilePaths = @(
    ".\\PBIRESTAPIComm.tests.arrow.helpers.query.pq",
    ".\\PBIRESTAPIComm.tests.arrow.staticfixture.query.pq",
    ".\\PBIRESTAPIComm.tests.arrow.compressed.datedim.query.pq",
    ".\\PBIRESTAPIComm.tests.apps.query.pq",
    ".\\PBIRESTAPIComm.tests.dashboards.query.pq",
    ".\\PBIRESTAPIComm.tests.dataflows.query.pq",
    ".\\PBIRESTAPIComm.tests.datasets.nofallback.query.pq",
    ".\\PBIRESTAPIComm.tests.datasets.parity.query.pq",
    ".\\PBIRESTAPIComm.tests.datasets.query.pq",
    ".\\PBIRESTAPIComm.tests.multievaluate.query.pq",
    ".\\PBIRESTAPIComm.tests.reports.query.pq",
    ".\\PBIRESTAPIComm.tests.groups.query.pq",
    ".\\PBIRESTAPIComm.tests.pipelines.query.pq",
    ".\\PBIRESTAPIComm.tests.scorecards.query.pq",
    ".\\PBIRESTAPIComm.tests.proof.query.pq",
    ".\\PBIRESTAPIComm.tests.showdata.query.pq",
    ".\\PBIRESTAPIComm.tests.connector.proof.query.pq"
)

$ConnectorSourcePath = (Resolve-Path -Path $RelConnectorSourcePath).Path
$NoFallbackGuardPassed = Test-NoFallbackCallChain -ConnectorFilePath $ConnectorSourcePath
if(!$NoFallbackGuardPassed){
    Write-Error "Static no-fallback guard failed. Remove ExecuteDax->ExecuteQuery references before running tests."
    return 0
}

if($TestFileName -and $TestFileName.Count -gt 0){
    $RequestedTestNames = @()
    foreach($Name in $TestFileName){
        $RequestedTestNames += ($Name -split ',')
    }

    $RequestedTestNames = $RequestedTestNames |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne "" }

    $FilteredRelQueryFilePaths = @()
    foreach($RelPath in $RelQueryFilePaths){
        $LeafName = Split-Path -Path $RelPath -Leaf
        $Matched = $false

        foreach($RequestedName in $RequestedTestNames){
            if($RequestedName -eq $LeafName -or $RequestedName -eq $RelPath -or $RequestedName -eq $RelPath.Replace(".\\", "")){
                $Matched = $true
            }
        }

        if($Matched){
            $FilteredRelQueryFilePaths += $RelPath
        }
    }

    if($FilteredRelQueryFilePaths.Count -eq 0){
        Write-Error "No test files matched the provided -TestFileName value(s): $($RequestedTestNames -join ', ')"
        Write-Error "Available test files: $($RelQueryFilePaths -join ', ')"
        return 0
    }

    $RelQueryFilePaths = $FilteredRelQueryFilePaths
    Write-Host "Running selected test files: $($RelQueryFilePaths -join ', ')"
}

# Get full path because PQTest expects that.
# Resolve the mez path WITHOUT requiring the file to already exist (a fresh
# clone has no compiled output yet). Anchor to the repo root so the output
# directory can never be doubled up (for example bin\AnyCPU\Debug\bin\...).
$RepoRoot = (Resolve-Path -Path ".").Path
$ExtensionFilePath = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot ($RelExtFilePath -replace '^\.\\', '')))
$ExtensionOutputDir = Split-Path -Path $ExtensionFilePath -Parent
$QueryCredFilePath = (Resolve-Path -Path $RelQueryCredFilePath).Path
$QueryFilePaths = @()
foreach($RelQueryFilePath in $RelQueryFilePaths){
    $QueryFilePaths += (Resolve-Path -Path $RelQueryFilePath).Path
}

# Compile Check    
if($Compile -eq $True){

    # Remove any stale or duplicated build artifacts before compiling so a
    # previous run can never leave behind a second .mez that PQTest might
    # pick up. This is the root-cause guard for the duplicate/nested
    # bin\AnyCPU\Debug\bin\... outputs and the bare ".mez" file.
    if(Test-Path -LiteralPath $ExtensionOutputDir){
        Get-ChildItem -Path $ExtensionOutputDir -Recurse -Filter "*.mez" -ErrorAction SilentlyContinue |
            ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue }
        # A nested output directory (bin\AnyCPU\Debug\bin) is always junk from a
        # doubled path; remove it if present.
        $NestedBin = Join-Path $ExtensionOutputDir "bin"
        if(Test-Path -LiteralPath $NestedBin){
            Remove-Item -LiteralPath $NestedBin -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Setup target compile. Strip ONLY the trailing ".mez" extension. The old
    # form used -replace ".mez" where "." is a regex wildcard, which could
    # corrupt the target path; anchor to the end and escape the dot instead.
    $Target = $ExtensionFilePath -replace '\.mez$', ''
    Write-Host "Compile Connector: $($Target)"

    # Run compile
    .\CI\PQTest\MakePQX.exe compile --target $Target

    # Verify the compile produced EXACTLY one .mez at the expected location.
    # Any other outcome means the build environment is misconfigured and must
    # be fixed before tests run against a possibly stale connector.
    $ProducedMez = @(Get-ChildItem -Path $ExtensionOutputDir -Recurse -Filter "*.mez" -ErrorAction SilentlyContinue)
    if($ProducedMez.Count -ne 1){
        Write-Error "Compile produced $($ProducedMez.Count) .mez file(s); expected exactly 1. Files: $(( $ProducedMez | ForEach-Object { $_.FullName }) -join '; ')"
        return 0
    }
    if($ProducedMez[0].FullName -ne $ExtensionFilePath){
        Write-Error "Compiled .mez is at an unexpected path: $($ProducedMez[0].FullName). Expected: $ExtensionFilePath"
        return 0
    }
}

# Guard the test phase too: refuse to run if the expected connector is missing
# or if any stray .mez exists that could shadow it.
if(!(Test-Path -LiteralPath $ExtensionFilePath)){
    Write-Error "Connector not found: $ExtensionFilePath. Run with -Compile `$True to build it."
    return 0
}
$AllMez = @(Get-ChildItem -Path $ExtensionOutputDir -Recurse -Filter "*.mez" -ErrorAction SilentlyContinue)
if($AllMez.Count -gt 1){
    Write-Error "Multiple .mez files found under $ExtensionOutputDir; remove stale builds. Files: $(( $AllMez | ForEach-Object { $_.FullName }) -join '; ')"
    return 0
}
  
# Setup credentials
# Keep auth kind configurable for local and CI parity. Default matches PQTest-supported OAuth2.
$CredentialJson = @{
    AuthenticationKind = $AuthenticationKind
    AuthenticationProperties = @{
        AccessToken = $AccessToken
    }
    PrivacySetting = "None"
    Permissions = @()
} | ConvertTo-Json -Compress

Write-Host "Using $AuthenticationKind authentication credential:"
# Redact the OAuth bearer token in console/log output. The raw token is still
# piped to PQTest via $X below — only the diagnostic echo is redacted so that
# Tee-Object'd run logs (and AI-agent transcripts) do not capture secrets.
$RedactedCredentialJson = $CredentialJson -replace '("AccessToken"\s*:\s*")[^"]+(")', '$1<REDACTED>$2'
Write-Host $RedactedCredentialJson

$X = $CredentialJson

$Result = $null
$Result = $X | & $PQTestExe set-credential `
                --extension $ExtensionFilePath `
				--queryFile $QueryCredFilePath `
				--prettyPrint

try {
    $TestSetCredential = $Result | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse set-credential response: $Result"
    return 0
}

if(!$TestSetCredential -or !($TestSetCredential.Status -like 'Success')){
    $CredentialErrorMessage = if($TestSetCredential -and $TestSetCredential.Error) { [string]$TestSetCredential.Error.Message } else { [string]$Result }
    Write-Error "Failed to create credential: $CredentialErrorMessage"
    return 0
}
else{
    Write-Host "Credential Successfully Created"
}

# Now Run The Tests
$TestRunSummary = @()
$TestFileCount = $QueryFilePaths.Count
$TestIndex = 0

foreach($QueryFilePath in $QueryFilePaths){
    $TestIndex++
    $TestLeaf = Split-Path -Path $QueryFilePath -Leaf
    # Emit a heartbeat before each test so long-running tests do not look like a
    # hang. A single test file can take 60-120 seconds (particularly the Arrow
    # parsing tests), and without this line the CI log shows a silent gap that
    # is easily mistaken for a stuck process.
    Write-Host "[RUN $TestIndex/$TestFileCount] $TestLeaf (starting at $((Get-Date).ToString('HH:mm:ss')))"
    $TestStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $Result = $null
    $Result = & $PQTestExe run-test --extension $ExtensionFilePath `
				                --queryFile $QueryFilePath `
				                --prettyPrint `
                                -ecf $TestFilePath

    $TestStopwatch.Stop()
    $ElapsedSeconds = [Math]::Round($TestStopwatch.Elapsed.TotalSeconds, 1)

    $TestResults = $Result | ConvertFrom-Json
    $Status = "Failed"
    $ErrorMessage = "Unknown error"
    $ErrorDetail = ""

    if($TestResults -and ($TestResults.Status -like 'Passed')){
        $Status = "Passed"
        $ErrorMessage = ""
        Write-Host "[PASS $TestIndex/$TestFileCount] $TestLeaf ($ElapsedSeconds`s)"
    }
    else {
        if($TestResults -and $TestResults.Error){
            $ErrorMessage = $TestResults.Error.Message
            if($TestResults.Error.PSObject.Properties.Name -contains "Detail"){
                $ErrorDetail = try { $TestResults.Error.Detail | ConvertTo-Json -Depth 15 -Compress } catch { [string]$TestResults.Error.Detail }
            }
        }
        elseif(!$TestResults){
            $ErrorMessage = "No Expected Test Results"
        }

        if([string]::IsNullOrWhiteSpace($ErrorDetail)){
            Write-Error "[FAIL $TestIndex/$TestFileCount] $TestLeaf ($ElapsedSeconds`s) - $ErrorMessage"
        }
        else {
            Write-Error "[FAIL $TestIndex/$TestFileCount] $TestLeaf ($ElapsedSeconds`s) - $ErrorMessage | Detail: $ErrorDetail"
        }
    }

    $TestRunSummary += [PSCustomObject]@{
        TestFile = $TestLeaf
        QueryFile = $QueryFilePath
        Status = $Status
        ElapsedSeconds = $ElapsedSeconds
        Error = if([string]::IsNullOrWhiteSpace($ErrorDetail)) { $ErrorMessage } else { "$ErrorMessage | Detail: $ErrorDetail" }
    }
}

Write-Host ""
Write-Host "Test file execution summary:"
$TestRunSummary | Select-Object TestFile, Status, ElapsedSeconds, Error | Format-Table -AutoSize

$FailedTests = $TestRunSummary | Where-Object { $_.Status -ne 'Passed' }
if($FailedTests.Count -gt 0){
    Write-Error "One or more test files failed: $($FailedTests.QueryFile -join '; ')"
    return 0
}

Write-Host "All split test files passed"