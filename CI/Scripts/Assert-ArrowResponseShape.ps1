<#
.SYNOPSIS
    Sanity-check that the live PBI tenant still returns Apache Arrow IPC
    bytes from the connector's executeDaxQueries endpoint.

.DESCRIPTION
    Tasks 1-5 of the Query-Agnostic Arrow IPC Parity Hardening epic depend
    on the live response actually being Arrow-encoded — otherwise the
    cell-by-cell parity assertions would silently degrade to JSON-vs-JSON
    parity and stop validating the Arrow IPC parser.

    This probe issues a tiny query against the configured GroupTestID +
    DatasetTestID and asserts:
      - Content-Type header contains `arrow`
      - First four bytes are the Arrow stream continuation marker (0xFFFFFFFF)
        OR the Arrow file magic (`ARROW1`)

    Run by Run-ArrowParsingGate.ps1 as a pre-flight step. Returns exit code
    0 on success, non-zero on degradation.
#>
param(
    [string]$VariablesPath
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)

if([string]::IsNullOrWhiteSpace($VariablesPath)){
    $VariablesPath = Join-Path $ScriptRoot "variables.test.json"
}

if(-not (Test-Path $VariablesPath)){
    Write-Error "Missing $VariablesPath. Run Setup-CI-Variables.ps1 first."
    exit 2
}

$Variables = Get-Content -Path $VariablesPath -Raw | ConvertFrom-Json
$GroupId = $Variables.GroupTestID
$DatasetId = $Variables.DatasetTestID

if([string]::IsNullOrWhiteSpace($GroupId) -or [string]::IsNullOrWhiteSpace($DatasetId)){
    Write-Error "GroupTestID and DatasetTestID must be set."
    exit 2
}

# Authenticate using the same precedence as Run-PQTests.ps1.
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
$AccessToken = $TokenObject.Values.Substring(7)

$Url = "https://api.powerbi.com/v1.0/myorg/groups/$GroupId/datasets/$DatasetId/executeDaxQueries"
$Body = @{
    queries = @(@{ query = 'EVALUATE ROW("N", 1)' })
    serializerSettings = @{ includeNulls = $true }
} | ConvertTo-Json -Depth 4 -Compress

$Headers = @{
    Authorization = "Bearer $AccessToken"
    "Content-Type" = "application/json"
    Accept = "application/vnd.apache.arrow.stream, application/vnd.apache.arrow.file, application/octet-stream, application/json"
}

Write-Host "Probing $Url for Arrow IPC response..."
$Response = Invoke-WebRequest -Method Post -Uri $Url -Headers $Headers -Body $Body -ErrorAction Stop

$ContentType = $Response.Headers["Content-Type"]
if($ContentType -is [array]){ $ContentType = $ContentType -join ", " }

$Bytes = $Response.Content
if($Bytes -is [string]){
    $Bytes = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($Bytes)
}
$First4Hex = ($Bytes[0..3] | ForEach-Object { $_.ToString("x2") }) -join ""

Write-Host "Content-Type : $ContentType"
Write-Host "First4Hex    : $First4Hex"
Write-Host "Bytes        : $($Bytes.Length)"

$ctOk = $ContentType -match 'arrow'
$magicOk = ($First4Hex -eq "ffffffff") -or ($First4Hex -eq "41525241")  # "ARRA" prefix of ARROW1 magic
if($ctOk -and $magicOk){
    Write-Host "PASS: executeDaxQueries still returns Apache Arrow IPC."
    exit 0
}

Write-Error "FAIL: executeDaxQueries response has degraded from Arrow IPC. Content-Type='$ContentType' First4Hex='$First4Hex'. Live parity tests (Tasks 1-5) would silently downgrade to JSON-vs-JSON validation."
exit 1
