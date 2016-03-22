
$servers = gc @("\\ctyfs-a01s\dsw\mypow\BMSvrs.txt")
$originsource = "\\ctyfs-a01s\dsw\Misc\BRBsrc\*.txt"

function Test-Site {
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
    write-host "`r`nTesting:  $URL"
    $webclient.DownloadString($URL) | Out-Null 
}

#Test-Site "http://ctywsp-a03.ETDsoya.com:10001/"


foreach($srv in $servers){   
    #copy the txt files
    $networksrv = "\\"+$srv+"\c$\"    
    copy-item $originsource -destination $networksrv -recurse -force
    
        $objSites = [adsi]"IIS://$srv/W3SVC"
    Write-host $srv "::Start::"
    foreach ($objChild in $objSites.Psbase.children)
    {
        if($objChild.KeyType -eq "IIsWebServer"){
            $objChild.Name # is an id 
     Write-host        $objChild.ServerComment # is the description                
            $objChild.ServerState
            $objBindings = $objChild.ServerBindings
            $strBindings = ""
            foreach($objBinding in $objBindings)
            {
                $arrBindings = $objBinding.Split(':')
                $strPort = $arrBindings[1]
                $httpsrv = "http://"+$srv+".ETDsoya.com:$strPort/?_jojo=reload"
                if($strPort -ne "80"){
                Test-Site $httpsrv;}
                break;
            }
        }
    }
    
    #Write-host $networksrv " was deployed"
    #Write-host $httpsrv " was reloaded"
}
