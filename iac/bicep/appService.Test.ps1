param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]] $HostNames
)

$TestCases = @()

$HostNames.ForEach{ $TestCases += @{HostName = $_ } }
Describe 'Testing connection to Websites' {

    It 'Server pages over HTTPS' -TestCases $TestCases {
        try {
            $request = [System.Net.WebRequest]::Create("https://$HostName/")
            $request.AllowAutoRedirect = $false
            $statusCode = [int]$request.GetResponse().StatusCode
        }
        catch [System.Net.WebException] {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        $statusCode | Should -BeIn @(200, 404) -Because "the website requires HTTPS"
    }

    It 'Does not serves pages over HTTP' -TestCases $TestCases {
        try {
            $request = [System.Net.WebRequest]::Create("https://$HostName/")
            $request.AllowAutoRedirect = $false
            $statusCode = [int]$request.GetResponse().StatusCode
        }
        catch [System.Net.WebException] {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        $statusCode | Should -BeIn (300..399) -Because "HTTP is not secure"
    }
}