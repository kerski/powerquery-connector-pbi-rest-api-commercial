<#
.SYNOPSIS
    Captures a real Arrow IPC Stream response from the Power BI executeQueries
    endpoint and emits a deterministic, committed fixture used by the
    credential-free Arrow IPC parser tests (Task 6 of the Query-Agnostic
    Arrow IPC Parity Hardening epic).

.DESCRIPTION
    This helper is intended to be run **once** when the fixture needs to be
    refreshed. The captured raw bytes are written to
    `tests/fixtures/arrow-fixture-simple.hex` (single-line lowercase hex,
    suitable for inline embedding in M test queries via
    `Binary.FromText(..., BinaryEncoding.Hex)`).

    The fixture is a tiny, deterministic DAX result:
        EVALUATE ROW("N", 1, "Label", "hello")

    By committing the captured bytes we get a credential-free, fully
    deterministic regression test for the Arrow IPC stream parser. The
    test runner does NOT execute this script; it only consumes the
    committed fixture.

.PARAMETER OutputPath
    Destination hex file. Defaults to tests/fixtures/arrow-fixture-simple.hex.

.PARAMETER AuthenticationKind
    Matches Run-PQTests.ps1. OAuth2 is the default; the script uses
    Get-PowerBIAccessToken after Connect-PowerBIServiceAccount.
#>
param(
    [string]$OutputPath = ".\tests\fixtures\arrow-fixture-simple.hex",
    [ValidateSet("OAuth2", "Aad")]
    [string]$AuthenticationKind = "OAuth2"
)

$ErrorActionPreference = "Stop"

# Resolve repo root (this script lives in CI\Scripts).
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
Set-Location $RepoRoot

# Load variables.test.json for group/dataset IDs and credentials.
$VariablesPath = Join-Path $ScriptRoot "variables.test.json"
if(-not (Test-Path $VariablesPath)){
    throw "Could not find $VariablesPath. Run Setup-CI-Variables.ps1 first."
}
$Variables = Get-Content -Path $VariablesPath -Raw | ConvertFrom-Json

$GroupId = $Variables.GroupTestID
$DatasetId = $Variables.DatasetTestID

if([string]::IsNullOrWhiteSpace($GroupId) -or [string]::IsNullOrWhiteSpace($DatasetId)){
    throw "GroupTestID and DatasetTestID must be set in variables.test.json."
}

# Authenticate the same way Run-PQTests.ps1 does (env-var or config).
$UserName = if($env:PPU_USERNAME){ $env:PPU_USERNAME } elseif($Variables.PSObject.Properties.Name -contains "PPU_USERNAME"){ $Variables.PPU_USERNAME } elseif($Variables.PSObject.Properties.Name -contains "UserName"){ $Variables.UserName } else { $null }
$Password = if($env:PPU_PASSWORD){ $env:PPU_PASSWORD } elseif($Variables.PSObject.Properties.Name -contains "PPU_PASSWORD"){ $Variables.PPU_PASSWORD } elseif($Variables.PSObject.Properties.Name -contains "Password"){ $Variables.Password } else { $null }

Import-Module MicrosoftPowerBIMgmt -ErrorAction SilentlyContinue | Out-Null

if($UserName -and $Password){
    $Secret = $Password | ConvertTo-SecureString -AsPlainText -Force
    $Credentials = [System.Management.Automation.PSCredential]::new($UserName, $Secret)
    Connect-PowerBIServiceAccount -Credential $Credentials | Out-Null
}
else {
    Connect-PowerBIServiceAccount | Out-Null
}

$TokenObject = Get-PowerBIAccessToken
$AccessToken = $TokenObject.Values.Substring(7)  # strip "Bearer "

$Url = "https://api.powerbi.com/v1.0/myorg/groups/$GroupId/datasets/$DatasetId/executeQueries"

# Tiny, deterministic, query-agnostic-friendly DAX expression.
# - Two-column single-row result.
# - Single batch, no dictionaries, no nulls.
# Future fixtures can be added side-by-side under tests/fixtures/.
$Body = @{
    queries = @(
        @{ query = 'EVALUATE ROW("N", 1, "Label", "hello")' }
    )
    serializerSettings = @{ includeNulls = $true }
} | ConvertTo-Json -Depth 4 -Compress

$Headers = @{
    Authorization = "Bearer $AccessToken"
    "Content-Type" = "application/json"
    Accept = "application/vnd.apache.arrow.stream, application/vnd.apache.arrow.file, application/octet-stream, application/json"
}

Write-Host "Capturing Arrow IPC fixture from $Url"
$Response = Invoke-WebRequest -Method Post -Uri $Url -Headers $Headers -Body $Body -ErrorAction Stop

$ContentType = $Response.Headers["Content-Type"]
if($ContentType -is [array]){ $ContentType = $ContentType -join ", " }
Write-Host "Response Content-Type: $ContentType"

if($ContentType -notmatch 'arrow'){
    throw "Server responded with non-Arrow Content-Type '$ContentType'. The dataset must support Arrow IPC responses. Bytes captured: $($Response.RawContentLength)."
}

# Persist raw bytes both as hex (for inline M embedding) and as a .arrow
# binary (in case a future test wants a binary fixture instead).
$OutputAbs = if([System.IO.Path]::IsPathRooted($OutputPath)){ $OutputPath } else { Join-Path $RepoRoot $OutputPath }
$OutputDir = Split-Path -Parent $OutputAbs
if(-not (Test-Path $OutputDir)){
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$Bytes = $Response.Content
if($Bytes -is [string]){
    $Bytes = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($Bytes)
}

$HexBuilder = New-Object System.Text.StringBuilder
foreach($b in $Bytes){
    [void]$HexBuilder.Append($b.ToString("x2"))
}
$Hex = $HexBuilder.ToString()

Set-Content -Path $OutputAbs -Value $Hex -NoNewline -Encoding ASCII

$BinPath = [System.IO.Path]::ChangeExtension($OutputAbs, ".arrow")
[System.IO.File]::WriteAllBytes($BinPath, $Bytes)

Write-Host "Captured $($Bytes.Length) bytes."
Write-Host "Hex fixture: $OutputAbs"
Write-Host "Raw binary: $BinPath"
