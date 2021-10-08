param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]] $HostNames
)

$TestCases = @()

$HostNames.ForEach{ $TestCases += @{HostName = $_ } }
Describe 'Testing connection to Websites' {

    It ' <HostName> over HTTPS' -ForEach $TestCases {
        try {
            $request = [System.Net.WebRequest]::Create("https://$HostName")
            $request.AllowAutoRedirect = $false
            $statusCode = [int]$request.GetResponse().StatusCode
        }
        catch [System.Net.WebException] {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        $statusCode | Should -BeIn @(200, 404) -Because "the website requires HTTPS"
    }

    It ' <HostName> over HTTP' -ForEach $TestCases {
        try {
            $request = [System.Net.WebRequest]::Create("http://$HostName")
            $request.AllowAutoRedirect = $false
            $statusCode = [int]$request.GetResponse().StatusCode
        }
        catch [System.Net.WebException] {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        $statusCode | Should -BeIn (300..399) -Because "HTTP is not secure"
    }
}