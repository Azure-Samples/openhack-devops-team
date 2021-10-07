param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]] $HostNames
)

$TestCases = @()

$HostNames.ForEach{ $TestCases += @{HostName = $_ } }
Describe 'Testing connection to Websites' {

    It 'Server pages over HTTPS' -TestCases $TestCases {
        $request = [System.Net.WebRequest]::Create("https://$HostName/")
        $request.AllowAutoRedirect = $false
        $request.GetResponse().StatusCode |
        Should -BeIn @(200,404) -Because "the website requires HTTPS"
    }

    It 'Does not serves pages over HTTP' -TestCases $TestCases {
        $request = [System.Net.WebRequest]::Create("http://$HostName/")
        $request.AllowAutoRedirect = $false
        $request.GetResponse().StatusCode | 
        Should -BeIn (300..399) -Because "HTTP is not secure"
    }
}