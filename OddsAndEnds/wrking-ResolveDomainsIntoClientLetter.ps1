function EmailMe ($subject , $body , $attachment ) {
[string[]]$to = "firep stan <firep@disenza.com>"
    $smtp = "internal.disenzahost.com"; $from = "computer.chi@disenza.com"
    $attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp
}

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
##for Dellssoya
$httppathSource = (Curlit "http://ctyut-a04.ETDsoya.com/support/Domains/$dt.txt") -split '\r\n' | sort | Get-Unique
##for Parissoya
$httppathSource += (Curlit "http://ctyut-a04.ETDsoya.com/support/Domains/Parissoya`_$dt.txt") -split '\r\n' | sort | Get-Unique
##for ParisHH
$httppathSource += (Curlit "http://ctyut-a04.ETDsoya.com/support/Domains/LKdisenzahost.txt") -split '\r\n' | sort | Get-Unique
$httppathSource > "E:\disenza\scripts\out\Domains\TRDellsDomains.txt"
$rootpath = "E:\disenza\scripts\out\Domains\"
$ErrorActionPreference = "SilentlyContinue"

$archiveDomains = "$rootpath`_$($dt)\"

$DellssoyaIPpattern = "123\.45\.67\.\d{1,3}"
$RedirectServerIP = "123\.45\.67\.5\b"
$ParisIPpattern = "84\.18\.168\.\d{1,3}"
$zonefileLog = "E:\disenza\scripts\out\Domains\$dt.zone.txt"; $zonefile = "";
$jsonClients = @() ; $jsonClientslog = "E:\disenza\scripts\out\Domains\$dt.json"
$newRedirIP = "23.100.43.208"
## use a server with powershell v3 to be able to use Resolve-DnsName cmdlet


$timetaken = measure-command {

$i=0;
foreach($clientShortDomain in $httppathSource){
    if(($clientShortDomain -ne '') -and ($clientShortDomain -ne $null) -and ($clientShortDomain -notcontains " ")){ #-and ($i -lt 10)){
    write-host $clientShortDomain -f red

    $points2Dells = $false; $isRedirectServer = $false; $DellsIP = $null

            $clientshort = ($clientShortDomain -split "`_")[0]
            $Domain = ($clientShortDomain -split "`_")[1] #-replace ".txt",""
            $outsideIP = $null
            $dnsinfoJson = ($plain = Resolve-DnsName $Domain.ToString()) | ConvertTo-Json
            write-host $plain.IPAddress -f red -b yellow
            $dnsinfoPS = $dnsinfoJson | ConvertFrom-Json

            <## TEST IF IT MATCHES ip4address #>
            if($dnsinfoPS.IPAddress -ne $null){
                $DellsIP = [regex]::matches($dnsinfoPS.IPAddress, $DellssoyaIPpattern)
                if($DellsIP -eq $null){$DellsIP =[regex]::matches($dnsinfoPS.IP4Address, $DellssoyaIPpattern)}
                write-host "1234" -f DarkRed -b white
            }
            if($DellsIP -eq $null){
                if($plain.IPAddress -eq $null){$DellsIP = $plain.IPAddress}
                if($DellsIP -eq $null){$DellsIP = $plain.IP4Address}
                write-host "567" -f DarkRed -b white
            }
            write-host "Dellsip: " $DellsIP
            #break;break;


            if($DellsIP -ne $null){
                $points2Dells = $true;
                ##
                ## check if redirect server:
                $isRedirectServer = [regex]::IsMatch($DellsIP, $RedirectServerIP)
            }
            else{
                if($dnsinfoPS.IPAddress -ne $null){$outsideIP = $dnsinfoPS.IPAddress}
                if(($outsideIP -eq $null) -and ($dnsinfoPS.IP4Address -ne $null)){
                    $outsideIP = $dnsinfoPS.IP4Address
                }
            }
            $isParisIP = [regex]::IsMatch($outsideIP, $ParisIPpattern)
            if($isParisIP){
                $points2Dells = $true
            }

            write-host $outsideIP[0].ToString()
            ##############  BUILD THE JSON DATA
            $firstletter = $clientshort.substring(0,1)
            <# IS THIS A NEW CLIENTSHORT COLLECTION?#>

            $ClientsDomains = @{}
            $ClientsDomains.Alpha = $firstletter  ## for sorting but may not be necessary
            $ClientsDomains.ClientShortname = $clientshort
            $ClientsDomains.CheckTime = get-date -Format "yyyy-MM-dE:hh:mm"
            $ClientsDomains.aliasIPresolves = $false
            $ClientsDomains.name = $Domain
            if($isRedirectServer){
                $ClientsDomains.cname = ""
            }
            else{
                ## create the new cname alias and resolve to check if it is already created on our new alias.TSHprod.com Domain.
                $ClientsDomains.cname = $Domain.replace(".","-")+".alias.TSHprod.com"
                $aliasresolvedIP = (Resolve-DnsName $($ClientsDomains.cname)).IPAddress
                $ClientsDomains.aliasIPresolves = $false
                if($aliasresolvedIP -eq $DellsIP){
                    $ClientsDomains.aliasIPresolves = $true
                }

            }

            $ClientsDomains.points2Dells = $points2Dells
            $ClientsDomains.points2DellsRedirectServer = $isRedirectServer
            $ClientsDomains.instructions = ""
            $ClientsDomains.Maxvalueis = $plain

            if($isRedirectServer){
                $ClientsDomains.dnsrec = "A"
                $ClientsDomains.Maxshouldbevalue = $newRedirIP
            }
            else{
                $ClientsDomains.dnsrec = "CNAME"
            }
            oni
            if($Domain -match ".staged.disenzaone.com"){
                $ClientsDomains.cname = ($Domain -split ("`."))[0]+".staged.disenza.com"
                $ClientsDomains.instructions = "When the migration occurs this new Domain will be created for the staged site."
               #EmailMe -subject "$Domain has to be changed" -body "IIS update via OD is required to add the new staged Domain."
            }
            if($DellsIP -ne $null){
                $ClientsDomains.ipaddress = $DellsIP[0].ToString()
                if(!$isRedirectServer -and ($Domain -notmatch "temp.disenza.com") -and ($Domain -notmatch "staged.disenzaone.com") ){
                    $ClientsDomains.instructions = "Create a $($ClientsDomains.dnsrec) record to point $Domain to $($ClientsDomains.cname)"
                    $zonefile +=  $Domain.replace(".","-")+".alias`t900`tA`t"+$DellsIP+"`r`n"
                }
                else{$ClientsDomains.instructions = "Create an $($ClientsDomains.dnsrec) record to point $Domain to $newRedirIP"}
            } else {
                $ClientsDomains.ipaddress = $outsideIP[0].ToString()
            }

            $jsonClients += $ClientsDomains  ## this appends the Domain data fully to the

            #######################################################

            $DomainLog += "`t"+$newDomainfile.replace(".txt","`r`n")

            Sleep 2

            $i++

    }

}


$jsonClients | ConvertTO-Json -Depth 3 | out-file $jsonClientslog  ### this is the source of our Domain store
$zonefile | out-file $zonefileLog
$clientInstructions | out-file $clientInstructionsFile
$DomainLog + "`r`n`r`n" + $zonename | out-file $DomainLogfile
#notepad $DomainLogfile
}

###  NO MORE BOM with this encoding conversion
$MyFile = Get-Content $jsonClientslog
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
[System.IO.File]::WriteAllLines($jsonClientslog, $MyFile, $Utf8NoBomEncoding)
### ________

$utility = gc env:computername
EmailMe -subject "Daily DNS resolution" -body "This job is on
Server:              $utility
Location:            E:\git\repos\ds-scripts\Chicago\DNS\ResolveDomainsIntoClientLetter.ps1
Output attachment:   $jsonClientslog
Report Runtime:      $timetaken" -attachment $jsonClientslog




notepad $zonefileLog
