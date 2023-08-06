<#
    Author: John Kerski
    Description: This script runs the proof-of-concept Continuous Integration of a custom connector.

    Dependencies: Premium Per User license purchased and assigned to UserName and UserName has admin right to workspace.
#>
#Install Powershell Module if Needed
if (Get-Module -ListAvailable -Name "MicrosoftPowerBIMgmt") {
    Write-Host "MicrosoftPowerBIMgmt already installed"
} else {
    Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser -AllowClobber -Force
}

#Check if we are running locally or in a pipeline
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
$TestFilePath = (Resolve-Path -Path $RelTestFilePath).Path

# Clear Credentials
$Result = $null
$Result = .\CI\PQTest\PQTest.exe delete-credential --ALL

# Generate Token
$AccessToken = Get-PowerBIAccessToken
# Remove 'Bearer' from token
$AccessToken = $AccessToken.Values.Substring(7)

# Relative Extension File Path
$RelExtFilePath = ".\\bin\\AnyCPU\\Debug\\powerquery-connector-pbi-rest-api-commercial.mez"
$RelQueryCredFilePath = ".\\PBIRESTAPICommCredTemplate.query.pq"
$RelQueryFilePath =  ".\\PBIRESTAPIComm.query.pq"

# Get full path because PQTest expects that
$ExtensionFilePath = (Resolve-Path -Path $RelExtFilePath).Path
$QueryCredFilePath = (Resolve-Path -Path $RelQueryCredFilePath).Path
$QueryFilePath = (Resolve-Path -Path $RelQueryFilePath).Path

$Template = $null
$Template = .\CI\PQTest\PQTest.exe credential-template --extension $ExtensionFilePath `
                                             --queryFile $QueryCredFilePath
# Output Template to Console for monitoring
Write-Host $Template

# Update Template
$Template = $Template.Replace('OAuth2','AAD')
$Template = $Template.Replace('$$ACCESS_TOKEN$$',$AccessToken)

$X = $Template | ConvertFrom-Json | ConvertTo-Json -Compress

$Result = $null
$Result = $X | .\CI\PQTest\PQTest.exe set-credential `
                --extension $ExtensionFilePath `
				--queryFile $QueryCredFilePath `
				--prettyPrint

$TestSetCredential = $Result | ConvertFrom-Json

if(!$TestSetCredential -and !($TestSetCredential.Status -like 'Success')){
    Write-Error "Passed"
    return 0
}
else{
    Write-Host "Credential Successfully Created"
}

# Now Run The Tests
$Result = $null

$Result = .\CI\PQTest\PQTest.exe run-test --extension $ExtensionFilePath `
				            --queryFile $QueryFilePath `
				            --prettyPrint `
                            -ecf $TestFilePath

$TestResults = $Result | ConvertFrom-Json

if(!$TestResults){
    Write-Error "No Expected Test Results"
    #return 0
}
elseif(!($TestResults.Status -like 'Passed') -or $TestResults.RowCount -gt 0){
    Write-Error $TestResults.Error.Message
    return 0
}
else {

    Write-Host "Test Results Passed"
}