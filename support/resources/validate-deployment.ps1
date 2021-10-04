<#

.SYNOPSIS
This script can be used to check the status of a classroom after is has been started in the Cloud Sandbox. 

This script has specficially been authored to check the lab microsoft-open-hack-devops and will not currently validate any other OpenHack labs.

.DESCRIPTION
To use this script, you will need to navigate to a classroom in the Cloud Sandbox and enter the lab view. 

From the lab view, click the List Credentials button, and then export the CSV. 

This script will take the path of that script as in input and use the credentials to enumerate all of the subscriptions within it.

.EXAMPLE
./validate-deployment.ps1 -LabCredentialsFilePath $env:HOMEPATH\Downloads\credentials.csv

.NOTES
This script should only be run at one hour after you have initiated the lab. Running it prior to that will certainly lead to results which lead you to believe the lab has not provisioned successfully, when in fact it is probably just still spinning up.

.LINK
https://github.com/Azure-Samples/openhack-devops-proctor/

#>

Param (
    [Parameter(Mandatory=$false)]
    [String]
    $LabCredentialsFilePath = "credentials.csv",

    [Parameter(Mandatory=$false)]
    [String]
    $OutputFilePath = "classroom_checkresults.csv",

    [switch]
    $Force
)

if (-Not (Test-Path $LabCredentialsFilePath -PathType Leaf)) {
  Write-Error -Message "Unable to find CSV at the path provided." -Category InvalidData
}

$InputFile = @(Import-Csv -Path $LabCredentialsFilePath -Header "PortalUsername","PortalPassword","AzureSubscriptionId","AzureDisplayName","AzureUsername","AzurePassword" | Where-Object AzureUserName -like "hacker*" | Sort-Object AzureSubscriptionId -Unique)

if (Test-Path $OutputFilePath -PathType Leaf) {
  if ($Force) {
    Remove-Item -Path $OutputFilePath
  } else {
    $_ = Read-Host "Found previous output. Would you like to delete it? (y/n)?"

    if ($_.ToLower() -eq "y") {
        Remove-Item -Path $OutputFilePath
    }
  }
}

Write-Host "Storing validation results at $OutputFilePath" -ForegroundColor Green

Add-Content -Path $OutputFilePath -Value '"SiteFound","POIFound","TripsFound","UserFound","UserJavaFound","TripViewerUrl","AzureUsername","AzurePassword","SubscriptionId","TenantURL"'

for ($i = 0; $i -lt $InputFile.Count; $i++) {
  $_ = $InputFile[$i]

  if ($_.AzureUsername -eq "Azure UserName" -and $_.AzurePassword -eq "Azure Password") {
    continue;
  }

  $PortalUsername = $_.PortalUsername
  $PortalPassword = $_.PortalPassword
  $AzureUsername = $_.AzureUsername
  $AzurePassword = $_.AzurePassword
  $AzureSubscriptionId = $_.AzureSubscriptionId
  $AzureDisplayName = $_.AzureDisplayName

  $AzureSecurePassword = ConvertTo-SecureString $AzurePassword -AsPlainText -Force
  $Credential = New-Object System.Management.Automation.PSCredential ($AzureUsername, $AzureSecurePassword)
  $TenantDomain = $AzureUsername.Split("@")[1]
  $TenantUrl = "https://portal.azure.com/$TenantDomain"

  Write-Host "Processing record for $AzureUsername" -ForegroundColor Yellow

  $Account = Connect-AzAccount -Credential $Credential -Subscription $AzureSubscriptionId

  $ResourceGroup = Get-AzResourceGroup | Where-Object ResourceGroupName -like "openhack*" | Select-Object -first 1
  $ResourceGroupName = $ResourceGroup.ResourceGroupName
  $TeamName = $ResourceGroupName -Replace ".{2}$"

  $RowToAppend = '"True",'

  $_poi = Get-AzWebApp -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -eq "$($TeamName)poi" }
  $_trips = Get-AzWebApp -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -eq "$($TeamName)trips" }
  $_userprofile = Get-AzWebApp -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -eq "$($TeamName)userprofile" }
  $_userjava = Get-AzWebApp -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -eq "$($TeamName)userjava" }
  $_tripviewer = Get-AzWebApp -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -eq "$($TeamName)tripviewer" }

  $_status = Invoke-WebRequest "http://$($_poi.DefaultHostName)/api/healthcheck/poi" | % {$_.StatusCode}
  if ($_status -eq 200) {
    $RowToAppend += '"True",'
  } else {
    $RowToAppend += '"False",'
  }

  $_status = Invoke-WebRequest "http://$($_trips.DefaultHostName)/api/healthcheck/trips" | % {$_.StatusCode}
  if ($_status -eq 200) {
    $RowToAppend += '"True",'
  } else {
    $RowToAppend += '"False",'
  }

  $_status = Invoke-WebRequest "http://$($_userprofile.DefaultHostName)/api/healthcheck/user" | % {$_.StatusCode}
  if ($_status -eq 200) {
    $RowToAppend += '"True",'
  } else {
    $RowToAppend += '"False",'
  }

  $_status = Invoke-WebRequest "http://$($_userjava.DefaultHostName)/api/healthcheck/user-java" | % {$_.StatusCode}
  if ($_status -eq 200) {
    $RowToAppend += '"True",'
  } else {
    $RowToAppend += '"False",'
  }

  $RowToAppend += "`"http://$($_tripviewer.DefaultHostName)`",`"$PortalUsername`",`"$PortalPassword`",`"$AzureSubscriptionId`",`"$TenantUrl`""

  Add-Content -Path $OutputFilePath -Value $RowToAppend

  Write-Host "Done for $AzureUsername"
}
