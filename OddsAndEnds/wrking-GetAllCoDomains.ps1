function Curlit {
    param($URL)
    trap{
        write-host "Failed. Details: $($_.Exception)"        
    }
    $webclient = New-Object Net.WebClient
    # The next 5 lines are required if your network has a proxy server
    <#    $webclient.Credentials = [System.Net.CredentialCache]::DefaultCredentials
    if($webclient.Proxy -ne $null)     {
        $webclient.Proxy.Credentials = `
                [System.Net.CredentialCache]::DefaultNetworkCredentials
    }#>
    # This is the main call
    #write-host "`r`nTesting:  $URL"
    $webclient.DownloadString($URL) #| Out-Null 
}

$dt = get-date -Format "yyyyMMdd"
##for dsoya
$httppathSource = (Curlit "http://ctyut-a04.ETDsoya.com/support/Domains/$dt.txt") -split '\r\n' | sort | Get-Unique
##for lsoya
$httppathSource += (Curlit "http://ctyut-a04.ETDsoya.com/support/Domains/Parissoya`_$dt.txt") -split '\r\n' | sort | Get-Unique
##for l2soya
$httppathSource += (Curlit "http://ctyut-a04.ETDsoya.com/support/Domains/LKdisenzahost.txt") -split '\r\n' | sort | Get-Unique
$httppathSource > "c:\powershell\out\Domains\SoyaDomains.txt"