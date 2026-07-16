<#
.SYNOPSIS
    Runs CI/Scripts/Probe-MultiEvaluate.py using a Power BI token acquired via PowerShell.

.DESCRIPTION
    Avoids MSAL authority/ROPC quirks in Python by acquiring a token with
    MicrosoftPowerBIMgmt first, then forwarding --token to the Python probe.
#>
param(
    [string]$VariablesPath = ".\CI\Scripts\variables.test.json",
    [string]$QueryFile = ".\tests\fixtures\multi_evaluate_datetime_probe.dax",
    [int]$ExpectedStreams = 2,
    [string]$OutputPath = ".\artifacts\multi-eval-python-canonical.json",
    [ValidateSet("rest", "connector")]
    [string]$PayloadMode = "connector",
    [string]$GroupId,
    [string]$DatasetId
)

$ErrorActionPreference = "Stop"

if(-not (Test-Path -Path $VariablesPath)){
    throw "Variables file not found: $VariablesPath"
}

$v = Get-Content -Path $VariablesPath -Raw | ConvertFrom-Json

$user = if([string]::IsNullOrWhiteSpace("$env:PPU_USERNAME")) {
    if([string]::IsNullOrWhiteSpace([string]$v.PPU_USERNAME)) { [string]$v.UserName } else { [string]$v.PPU_USERNAME }
} else {
    "$env:PPU_USERNAME"
}
$pass = if([string]::IsNullOrWhiteSpace("$env:PPU_PASSWORD")) {
    if([string]::IsNullOrWhiteSpace([string]$v.PPU_PASSWORD)) { [string]$v.Password } else { [string]$v.PPU_PASSWORD }
} else {
    "$env:PPU_PASSWORD"
}

if([string]::IsNullOrWhiteSpace($user) -or [string]::IsNullOrWhiteSpace($pass)){
    throw "PPU credentials missing in env and variables file"
}

$secure = ConvertTo-SecureString $pass -AsPlainText -Force
$cred = [System.Management.Automation.PSCredential]::new($user, $secure)
Connect-PowerBIServiceAccount -Credential $cred | Out-Null
$token = (Get-PowerBIAccessToken).Authorization -replace '^Bearer\s+',''

$groupArg = if([string]::IsNullOrWhiteSpace($GroupId)) { @() } else { @("--group-id", $GroupId) }
$datasetArg = if([string]::IsNullOrWhiteSpace($DatasetId)) { @() } else { @("--dataset-id", $DatasetId) }

$args = @(
    "CI/Scripts/Probe-MultiEvaluate.py",
    "--variables", $VariablesPath,
    "--query-file", $QueryFile,
    "--expected-streams", "$ExpectedStreams",
    "--output", $OutputPath,
    "--token", $token,
    "--payload-mode", $PayloadMode
) + $groupArg + $datasetArg

& .\.venv\Scripts\python.exe @args
