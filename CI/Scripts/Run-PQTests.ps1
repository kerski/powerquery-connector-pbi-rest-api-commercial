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

    Example: 
        -Compile $False

.EXAMPLE
    ./Run-PBITests.ps1
    ./Run-PBITests.ps1 -Compile $False
#>
param([Boolean]$Compile = $True)

# Install Powershell Module if Needed
if (Get-Module -ListAvailable -Name "MicrosoftPowerBIMgmt") {
    Write-Host "MicrosoftPowerBIMgmt already installed"
} else {
    Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser -AllowClobber -Force
}

# Check if we are running locally or in a pipeline
if(${env:BUILD_SOURCEVERSION}) # assumes this only exists in Azure Pipelines
{
    # Get from environment
    $UserName = "${env:PPU_USERNAME}"
    $Password = "${env:PPU_PASSWORD}"    
    #Set Password as Secure String
    $Secret = $Password | ConvertTo-SecureString -AsPlainText -Force
    $Credentials = [System.Management.Automation.PSCredential]::new($UserName,$Secret)
    #Connect to Power BI
    Connect-PowerBIServiceAccount -Credential $Credentials

}
else { # Runs Local so will ask to sign in
    Connect-PowerBIServiceAccount
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
$RelQueryFilePaths = @(
    ".\\PBIRESTAPIComm.tests.apps.query.pq",
    ".\\PBIRESTAPIComm.tests.dashboards.query.pq",
    ".\\PBIRESTAPIComm.tests.dataflows.query.pq",
    ".\\PBIRESTAPIComm.tests.datasets.query.pq",
    ".\\PBIRESTAPIComm.tests.reports.query.pq",
    ".\\PBIRESTAPIComm.tests.groups.query.pq",
    ".\\PBIRESTAPIComm.tests.pipelines.query.pq",
    ".\\PBIRESTAPIComm.tests.scorecards.query.pq"
)
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
$Template = $null
$Template = & $PQTestExe credential-template --extension $ExtensionFilePath `
                                             --queryFile $QueryCredFilePath
# Output Template to Console for monitoring
Write-Host $Template

# Update Template
$Template = $Template.Replace('$$ACCESS_TOKEN$$',$AccessToken)

$X = $Template | ConvertFrom-Json | ConvertTo-Json -Compress

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