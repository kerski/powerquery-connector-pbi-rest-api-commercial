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
    [string[]]$TestFileName
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
    ".\\PBIRESTAPIComm.tests.apps.query.pq",
    ".\\PBIRESTAPIComm.tests.dashboards.query.pq",
    ".\\PBIRESTAPIComm.tests.dataflows.query.pq",
    ".\\PBIRESTAPIComm.tests.datasets.nofallback.query.pq",
    ".\\PBIRESTAPIComm.tests.datasets.parity.query.pq",
    ".\\PBIRESTAPIComm.tests.datasets.query.pq",
    ".\\PBIRESTAPIComm.tests.reports.query.pq",
    ".\\PBIRESTAPIComm.tests.groups.query.pq",
    ".\\PBIRESTAPIComm.tests.pipelines.query.pq",
    ".\\PBIRESTAPIComm.tests.scorecards.query.pq"
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

# Get full path because PQTest expects that
$ExtensionFilePath = (Resolve-Path -Path $RelExtFilePath).Path
$QueryCredFilePath = (Resolve-Path -Path $RelQueryCredFilePath).Path
$QueryFilePaths = @()
foreach($RelQueryFilePath in $RelQueryFilePaths){
    $QueryFilePaths += (Resolve-Path -Path $RelQueryFilePath).Path
}

# Compile Check    
if($Compile -eq $True){

    # Setup target compile
    $Target = $($ExtensionFilePath -replace ".mez", "")
    Write-Host "Compile Connector: $($Target)"

    # Run compile
    .\CI\PQTest\MakePQX.exe compile --target $Target
}
  
# Setup credentials
# PQTest generates OAuth2 by default, but our connector uses AAD authentication.
# We need to manually construct an AAD credential template instead.
$CredentialJson = @{
    AuthenticationKind = "Aad"
    AuthenticationProperties = @{
        AccessToken = $AccessToken
    }
    PrivacySetting = "None"
    Permissions = @()
} | ConvertTo-Json -Compress

Write-Host "Using AAD authentication credential:"
Write-Host $CredentialJson

$X = $CredentialJson

$Result = $null
$Result = $X | & $PQTestExe set-credential `
                --extension $ExtensionFilePath `
				--queryFile $QueryCredFilePath `
				--prettyPrint

$TestSetCredential = $Result | ConvertFrom-Json

if(!$TestSetCredential -or !($TestSetCredential.Status -like 'Success')){
    Write-Error "Failed to create credential"
    return 0
}
else{
    Write-Host "Credential Successfully Created"
}

# Now Run The Tests
$TestRunSummary = @()

foreach($QueryFilePath in $QueryFilePaths){
    $Result = $null
    $Result = & $PQTestExe run-test --extension $ExtensionFilePath `
				                --queryFile $QueryFilePath `
				                --prettyPrint `
                                -ecf $TestFilePath

    $TestResults = $Result | ConvertFrom-Json
    $Status = "Failed"
    $ErrorMessage = "Unknown error"

    if($TestResults -and ($TestResults.Status -like 'Passed')){
        $Status = "Passed"
        $ErrorMessage = ""
        Write-Host "[PASS] $QueryFilePath"
    }
    else {
        if($TestResults -and $TestResults.Error){
            $ErrorMessage = $TestResults.Error.Message
        }
        elseif(!$TestResults){
            $ErrorMessage = "No Expected Test Results"
        }

        Write-Error "[FAIL] $QueryFilePath - $ErrorMessage"
    }

    $TestRunSummary += [PSCustomObject]@{
        TestFile = Split-Path -Path $QueryFilePath -Leaf
        QueryFile = $QueryFilePath
        Status = $Status
        Error = $ErrorMessage
    }
}

Write-Host ""
Write-Host "Test file execution summary:"
$TestRunSummary | Select-Object TestFile, Status, Error | Format-Table -AutoSize

$FailedTests = $TestRunSummary | Where-Object { $_.Status -ne 'Passed' }
if($FailedTests.Count -gt 0){
    Write-Error "One or more test files failed: $($FailedTests.QueryFile -join '; ')"
    return 0
}

Write-Host "All split test files passed"