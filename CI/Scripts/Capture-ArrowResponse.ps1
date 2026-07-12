<#
.SYNOPSIS
    Captures the RAW Arrow IPC bytes returned by the Power BI executeDaxQueries
    endpoint, bypassing the connector/PQTest credential masking.

.DESCRIPTION
    Calls POST v1.0/myorg/datasets/{datasetId}/executeDaxQueries with
    Accept: application/vnd.apache.arrow.stream and the exact flat payload the
    connector sends ({ "query": "<DAX>" }). Writes the raw response body to a
    .arrow file and a lowercase hex dump to a .hex file so the bytes can be
    replayed offline through PBIRESTAPIComm.ArrowFromBinary.

.PARAMETER Query
    The DAX query to execute. Defaults to the DateDim TOPN(10) proof query.

.PARAMETER DatasetId
    Dataset id. Defaults to DatasetTestID from CI/Scripts/variables.test.json.

.PARAMETER OutName
    Base file name (no extension) written under tests/fixtures/.

.EXAMPLE
    ./CI/Scripts/Capture-ArrowResponse.ps1
#>
param(
    [string]$Query = "EVALUATE TOPN(10,DateDim,DateDim[Date],DESC)",
    [string]$DatasetId,
    [string]$OutName = "arrow-fixture-datedim-live"
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$varsPath = Join-Path $repoRoot "CI\Scripts\variables.test.json"
if(!(Test-Path $varsPath)){ throw "Missing $varsPath" }
$vars = Get-Content -Raw -Path $varsPath | ConvertFrom-Json

if([string]::IsNullOrWhiteSpace($DatasetId)){ $DatasetId = $vars.DatasetTestID }

# Ensure an authenticated Power BI session. Reuse the existing one if present,
# otherwise sign in with the service account from variables.test.json.
try {
    $null = Get-PowerBIAccessToken -ErrorAction Stop
    Write-Host "Reusing existing Power BI session"
} catch {
    Write-Host "Connecting to Power BI service..."
    $sec = ConvertTo-SecureString $vars.PPU_PASSWORD -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($vars.PPU_USERNAME, $sec)
    Connect-PowerBIServiceAccount -Credential $cred | Out-Null
}

$auth = Get-PowerBIAccessToken -AsString   # "Bearer <token>"
$uri = "https://api.powerbi.com/v1.0/myorg/datasets/$DatasetId/executeDaxQueries"
$body = @{ query = $Query } | ConvertTo-Json -Compress

$fixturesDir = Join-Path $repoRoot "tests\fixtures"
if(!(Test-Path $fixturesDir)){ New-Item -ItemType Directory -Path $fixturesDir | Out-Null }
$arrowPath = Join-Path $fixturesDir ($OutName + ".arrow")
$hexPath   = Join-Path $fixturesDir ($OutName + ".hex")

Write-Host "POST $uri"
Write-Host "Query: $Query"

$resp = Invoke-WebRequest -Uri $uri -Method Post `
    -Headers @{ Authorization = $auth; Accept = "application/vnd.apache.arrow.stream" } `
    -ContentType "application/json" -Body $body `
    -SkipHttpErrorCheck

Write-Host "HTTP status: $($resp.StatusCode)"
$ctype = $resp.Headers["Content-Type"]
Write-Host "Content-Type: $ctype"

# Extract raw bytes regardless of how PowerShell surfaced the body.
$bytes = if($resp.RawContentStream){
    $ms = New-Object System.IO.MemoryStream
    $resp.RawContentStream.Position = 0
    $resp.RawContentStream.CopyTo($ms)
    $ms.ToArray()
} elseif($resp.Content -is [byte[]]) {
    $resp.Content
} else {
    [System.Text.Encoding]::UTF8.GetBytes([string]$resp.Content)
}

[System.IO.File]::WriteAllBytes($arrowPath, $bytes)
$hex = ([BitConverter]::ToString($bytes) -replace '-').ToLower()
Set-Content -Path $hexPath -Value $hex -NoNewline

Write-Host ""
Write-Host "Saved $($bytes.Length) bytes -> $arrowPath"
Write-Host "Hex           -> $hexPath"
$headLen = [Math]::Min(48, $hex.Length)
$tailLen = [Math]::Min(48, $hex.Length)
Write-Host ("HeadHex: " + $hex.Substring(0, $headLen))
if($hex.Length -gt $tailLen){
    Write-Host ("TailHex: " + $hex.Substring($hex.Length - $tailLen, $tailLen))
}
if($resp.StatusCode -ne 200){
    Write-Warning "Non-200 response; body may be a JSON error, not Arrow bytes."
    Write-Host ([System.Text.Encoding]::UTF8.GetString($bytes))
}
