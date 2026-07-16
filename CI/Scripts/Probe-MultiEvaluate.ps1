<#
.SYNOPSIS
    PowerShell baseline probe for multiple EVALUATE statements in executeDaxQueries.

.DESCRIPTION
    Posts a multi-EVALUATE DAX query to executeDaxQueries for the configured
    GroupTestID/DatasetTestID (from variables.test.json by default), splits the
    Arrow payload at EOS markers, and writes a canonical JSON artifact with
    response metadata and stream counts.

.PARAMETER VariablesPath
    Path to variables.test.json.

.PARAMETER GroupId
    Optional override for GroupTestID.

.PARAMETER DatasetId
    Optional override for DatasetTestID.

.PARAMETER QueryFile
    Path to UTF-8 DAX file containing one query object with multiple EVALUATE statements.

.PARAMETER OutputPath
    Output JSON file path.
#>
param(
    [string]$VariablesPath = ".\CI\Scripts\variables.test.json",
    [string]$GroupId,
    [string]$DatasetId,
    [string]$QueryFile = ".\tests\fixtures\multi_evaluate_datetime_probe.dax",
    [string]$OutputPath = ".\artifacts\multi-eval-powershell-canonical.json",
    [ValidateSet("rest", "connector")]
    [string]$PayloadMode = "connector"
)

$ErrorActionPreference = "Stop"

if(-not (Test-Path -Path $VariablesPath)){
    throw "Variables file not found: $VariablesPath"
}

$vars = Get-Content -Path $VariablesPath -Raw | ConvertFrom-Json
$resolvedGroupId = if([string]::IsNullOrWhiteSpace($GroupId)) { [string]$vars.GroupTestID } else { $GroupId }
$resolvedDatasetId = if([string]::IsNullOrWhiteSpace($DatasetId)) { [string]$vars.DatasetTestID } else { $DatasetId }

if([string]::IsNullOrWhiteSpace($resolvedGroupId) -or [string]::IsNullOrWhiteSpace($resolvedDatasetId)){
    throw "GroupId and DatasetId must be provided via params or variables.test.json"
}

if(-not (Test-Path -Path $QueryFile)){
    throw "Query file not found: $QueryFile"
}

$queryText = Get-Content -Path $QueryFile -Raw
$queryLines = $queryText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

$user = if([string]::IsNullOrWhiteSpace("$env:PPU_USERNAME")) {
    if([string]::IsNullOrWhiteSpace([string]$vars.PPU_USERNAME)) { [string]$vars.UserName } else { [string]$vars.PPU_USERNAME }
} else {
    "$env:PPU_USERNAME"
}
$pass = if([string]::IsNullOrWhiteSpace("$env:PPU_PASSWORD")) {
    if([string]::IsNullOrWhiteSpace([string]$vars.PPU_PASSWORD)) { [string]$vars.Password } else { [string]$vars.PPU_PASSWORD }
} else {
    "$env:PPU_PASSWORD"
}

if([string]::IsNullOrWhiteSpace($user) -or [string]::IsNullOrWhiteSpace($pass)){
    throw "PPU credentials missing in env and variables file"
}

$secure = $pass | ConvertTo-SecureString -AsPlainText -Force
$cred = [System.Management.Automation.PSCredential]::new($user, $secure)
Connect-PowerBIServiceAccount -Credential $cred | Out-Null

$token = (Get-PowerBIAccessToken).Authorization -replace '^Bearer\s+',''
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    Accept = "application/vnd.apache.arrow.stream,application/vnd.apache.arrow.file,application/octet-stream,application/json"
}

$payloadRecord = if($PayloadMode -eq "connector"){
    @{ query = $queryText }
}
else{
    @{
        queries = @(@{ query = $queryText })
        serializerSettings = @{ includeNulls = $true }
    }
}

$payload = $payloadRecord | ConvertTo-Json -Depth 8

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$resolvedGroupId/datasets/$resolvedDatasetId/executeDaxQueries"
$response = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -Body $payload

$bytes = $response.Content
$eos = [byte[]](0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00)

$segments = New-Object System.Collections.Generic.List[object]
$cursor = 0
while($cursor -lt $bytes.Length){
    $found = -1
    for($i = $cursor; $i -le ($bytes.Length - $eos.Length); $i++){
        $match = $true
        for($j = 0; $j -lt $eos.Length; $j++){
            if($bytes[$i + $j] -ne $eos[$j]){
                $match = $false
                break
            }
        }
        if($match){
            $found = $i
            break
        }
    }

    if($found -lt 0){
        $remaining = $bytes.Length - $cursor
        if($remaining -gt 0){
            $segments.Add([pscustomobject]@{ Index = $segments.Count; Length = $remaining })
        }
        break
    }

    $segLen = ($found + $eos.Length) - $cursor
    if($segLen -gt $eos.Length){
        $segments.Add([pscustomobject]@{ Index = $segments.Count; Length = $segLen })
    }
    $cursor = $found + $eos.Length
}

$firstHexLen = [Math]::Min($bytes.Length, 128)
$firstHex = if($firstHexLen -gt 0) {
    [System.BitConverter]::ToString($bytes[0..($firstHexLen - 1)]).Replace("-", "").ToLowerInvariant()
} else {
    ""
}

$jsonResultCount = $null
$jsonTableCounts = $null
if($response.Headers["Content-Type"] -like "*json*"){
    $obj = $bytes | ConvertFrom-Json
    $jsonResultCount = if($obj.results) { $obj.results.Count } else { 0 }
    $jsonTableCounts = @()
    for($k = 0; $k -lt $jsonResultCount; $k++){
        $r = $obj.results[$k]
        $jsonTableCounts += if($r.tables){ $r.tables.Count } else { 0 }
    }
}

$outputDir = Split-Path -Path $OutputPath -Parent
if(-not [string]::IsNullOrWhiteSpace($outputDir) -and -not (Test-Path -Path $outputDir)){
    New-Item -Path $outputDir -ItemType Directory | Out-Null
}

$artifact = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    endpoint = $uri
    payload_mode = $PayloadMode
    query_file = $QueryFile
    queries = $queryLines
    status_code = [int]$response.StatusCode
    content_type = [string]$response.Headers["Content-Type"]
    body_length = [int]$bytes.Length
    first128_hex = $firstHex
    stream_count = $segments.Count
    streams = $segments
    json_results_count = $jsonResultCount
    json_table_counts = $jsonTableCounts
}

# Known bad-pattern guard: in this environment the REST payload shape can
# yield a single empty-schema Arrow stream for multi-EVALUATE requests. Fail
# fast with an explicit signal so this is not treated as a valid parity result.
$emptySchemaSignature = "ffffffff3000000010000000"
$guardTriggered = ($PayloadMode -eq "rest") -and ($segments.Count -eq 1) -and ($bytes.Length -le 256) -and $firstHex.StartsWith($emptySchemaSignature)
$guardReason = if($guardTriggered) {
    "REST payload guard: one stream with known empty-schema Arrow signature detected. Use -PayloadMode connector for multi-EVALUATE parity."
} else {
    $null
}

$artifact.guard_triggered = $guardTriggered
$artifact.guard_reason = $guardReason

$artifact | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputPath -Encoding utf8
Write-Host "Saved canonical artifact: $OutputPath"
Write-Host ("Stream count: " + $segments.Count)

if($guardTriggered){
    Write-Error $guardReason
    exit 1
}
