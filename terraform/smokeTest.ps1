param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]] $HostNames=@()
)

if (!(Get-Module -Name Pester)) {
    Write-Host "Pester module does not exist. Installing ..."
    try {
        Install-Module Pester -AllowClobber -Force -Confirm:$False -SkipPublisherCheck
    }
    catch [Exception] {
        $_.message 
        exit
    }
}
Import-Module Pester

$container = New-PesterContainer `
-Path 'appService.Test.ps1' `
-Data @{ HostNames = $HostNames }
Invoke-Pester `
-Container $container `
-CI `
-OutputFormat JUnitXml