
$servers = gc @("\\ctyfs-a01s\dsw\mypow\testservers.txt")
$originsource = "\\ctyfs-a01s\dsw\Misc\BRBsrc\*.txt"

function Test-Site {
    param($URL)
    trap{
        write-host "Failed. Details: $($_.Exception)"
          <#
        $emailFrom = "my.email@address.com"
        # Use commas for multiple addresses
        $emailTo = "firep@disenzaswamy.com,firepatwork@gmail.com"
        $subject = "$URL down"
        $body = "This $URL site is down. Details: $($_.Exception)"
        $smtpServer = "smtp.server.to.use.for.relay"
        $smtp = new-object Net.Mail.SmtpClient($smtpServer)
        $smtp.Send($emailFrom, $emailTo, $subject, $body)  #> 
        exit 1
    }
    $webclient = New-Object Net.WebClient
    # The next 5 lines are required if your network has a proxy server
    <#    $webclient.Credentials = [System.Net.CredentialCache]::DefaultCredentials
    if($webclient.Proxy -ne $null)     {
        $webclient.Proxy.Credentials = `
                [System.Net.CredentialCache]::DefaultNetworkCredentials
    }#>
    # This is the main call
    write-host "`r`nTesting:  $URL"
    $webclient.DownloadString($URL) | Out-Null 
}

#Test-Site "http://ctywsp-a03.ETDsoya.com:10001/"


foreach($srv in $servers){   
    #copy the txt files
    $networksrv = "\\"+$srv+"\c$\"    
    copy-item $originsource -destination $networksrv -recurse -force
    
    $httpsrv = "http://"+$srv+".ETDsoya.com:10001/?_jojo=reload"
    Test-Site $httpsrv
    
    #Write-host $networksrv " was deployed"
    #Write-host $httpsrv " was reloaded"
}
