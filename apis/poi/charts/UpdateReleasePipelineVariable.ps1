<#
This script can be used in an Azure DevOps Release Pipeline to "commit" pipeline variables between stages of a pipeline (DevOps does not do this automatically in 
"Classic" (i.e. not YAML) pipelines) by calling the DevOps API.

- Create a pipeline variable in the pipeline (e.g. "BuildNumber")
- In the job properties for the stage that initialised the variable set the advanced property "Allow scripts to access the OAuth token" (the script needs this to call the API)
- Add a Powershell Task and set the FilePath to the script. Specify the two paramaters "VariableName" and "VariableValue". If you have already set the variable earlier in the stage
  you can reference the variable value using the usual syntax, i.e:

  -VariableName "BuildNumber" -VariableValue $(BuildNumber)

References to the pipeline variable in all subsequent stages of the pipeline should contain the new value.
#>
param (
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[string] $VariableName,
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[string] $VariableValue
)

function BasicAuthHeader()
## Construct a basic auth header
{
    param([string]$authtoken)

    $ba = (":{0}" -f $authtoken)
    $ba = [System.Text.Encoding]::UTF8.GetBytes($ba)
    $ba = [System.Convert]::ToBase64String($ba)
    $h = @{Authorization=("Basic{0}" -f $ba);ContentType="application/json"}
    return $h
}

# This script will only work if it can access the OAuth token
if (!$env:SYSTEM_ACCESSTOKEN)
{
    throw "System.AccessToken is null. Ensure that this job has access to the OAuth token (https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops&tabs=classic#systemaccesstoken)"
}

$h = BasicAuthHeader $env:SYSTEM_ACCESSTOKEN

$baseRMUri = $env:SYSTEM_TEAMFOUNDATIONSERVERURI + $env:SYSTEM_TEAMPROJECT
$releaseId = $env:RELEASE_RELEASEID

# get current release object
$getReleaseUri = $baseRMUri + "/_apis/release/releases/" + $releaseId + "?api-version=5.0"
$release = Invoke-RestMethod -Uri $getReleaseUri -Headers $h -Method Get

# update the pipeline variable
Write-Host ("Setting variable $VariableName to $VariableValue")

if (!$release.variables.($VariableName))
{
    throw "There is no release variable with the name $VariableName"
}

$release.variables.($VariableName).value = $VariableValue

# save the release object
$release2 = $release | ConvertTo-Json -Depth 100
$release2 = [Text.Encoding]::UTF8.GetBytes($release2)

Write-Host ("Updating release ...")

$updateReleaseUri = $baseRMUri + '/_apis/release/releases/' + $releaseId + '?api-version=5.0'
$n = Invoke-RestMethod -Uri $updateReleaseUri -Method Put -Headers $h -ContentType 'application/json' -Body $release2

Write-host "=========================================================="