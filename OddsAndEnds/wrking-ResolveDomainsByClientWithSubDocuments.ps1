function EmailMe ($subject , $body , $attachment ) {
[string[]]$to = "firep stan <firep@disenza.com>"
    $smtp = "internal.disenzahost.com"; $from = "DTcomputer.chi@disenza.com"
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
#$httppathSource = "http://ctyut-a04.ETDsoya.com/support/Domains/($dt).txt"

$httppathSource = (Curlit "http://ctyut-a04.ETDsoya.com/support/Domains/$dt.txt") -split '\r\n' | sort | Get-Unique

$rootpath = "E:\disenza\scripts\out\Domains\"
#$allLetterContainers = (gci $rootpathSource)  | sort Name -Descending
$ErrorActionPreference = "SilentlyContinue"

$archiveDomains = "$rootpath`_$($dt)\"
#$yesterday = ((get-date).AddDays(-1).Tostring("yyyyMMdd"))

$DellssoyaIPpattern = "123\.45\.67\.\d{1,3}"
$RedirectServerIP = "123\.45\.67\.5\b"

#$DomainLog = ""; $zonename = ""; $DomainLogfile = "E:\today\7\Domains.log"
#$clientInstructions = ""; $clientInstructionsFile = "E:\today\7\clientinstructions.log"
#clear-content $DomainLogfile; clear-content $clientInstructionsFile;
$jsonClients = @() ; $jsonClientslog = "E:\disenza\scripts\out\Domains$dt.json"

## use a server with powershell v3 to be able to use Resolve-DnsName cmdlet

$timetaken = measure-command {
foreach($clientShortDomain in $httppathSource){
    if(($clientShortDomain -ne '') -and ($clientShortDomain -ne $null) -and ($clientShortDomain -notcontains " ")){
    #if($dir -match $yesterday){ write-host $dir.FullName -f black -b Green
    write-host $clientShortDomain -f red
        #$todaysDomainsToCheck = gci $letter.FullName;

       #foreach($Domainfile in $todaysDomainsToCheck){
    $points2Dells = $false; $isRedirectServer = $false; $DellsIP = $null
    write-host $Domainfile
            $clientshort = ($clientShortDomain -split "`_")[0]
            $Domain = ($clientShortDomain -split "`_")[1] #-replace ".txt",""
            $outsideIP = $null
            #$newDomainsletter = "$archiveDomains$letter"
            #$newDomainfile = "$archiveDomains$letter\$clientshort`_$Domain.txt"
            #write-host $newDomainfile -f DarkCyan -b green

            #if(!(test-path $newDomainsletter)){New-Item $newDomainsletter -type Directory}

            #### >>>>>>>>>>  put this line back in if you want to resolve info:
            $dnsinfoJson = Resolve-DnsName $Domain.ToString() -Type ALL | ConvertTo-Json
            #$strdnsinfo = $dnsinfo | out-string

            $dnsinfoPS = $dnsinfoJson | ConvertFrom-Json

            <## TEST IF IT MATCHES ip4address #>
            $DellsIP = [regex]::matches($dnsinfoPS.IPAddress, $DellssoyaIPpattern)
            if($DellsIP -eq $null){$DellsIP =  [regex]::matches($dnsinfoPS.IP4Address, $DellssoyaIPpattern)}
            write-host $DellsIP
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
            <#
            if($points2Dells){$newDomainfile = $newDomainfile.Replace(".txt","____________-$DellsIP-.txt")}
            if($isRedirectServer){
                $newDomainfile = $newDomainfile.Replace(".txt",".....R.txt"); $zonename += "`t"+$Domain+"`t$DellsIP`r`n"}
            else{
            #>
            ## 1) put in logic for if the Domain is staged url going to disenzaone.com(YOUNGCONAW_youngconawaymc67.staged.disenzaone.com____________-312.94.12.24-) - maybe do nothing, is it still used?
            ## 2) what if the Domain contains a cname? do we want to tell them to delete the old one?  Do we create a new one? (www.reedsmith.com)

            ##>> Propose:
            # if you point to Dells - then we will create for you a new Domain .alias.TSHprod.com to point to that IP address.
            # if you have multiple IPs in Dells that means you may have a need for SSL encrypted VIP, so we should flag those for special attention.
            ##############  BUILD THE JSON DATA
            $firstletter = $clientshort.substring(0,1)
            <# IS THIS A NEW CLIENTSHORT COLLECTION?#>
            if($clientshort -ne $previousClientShort){
            $jsonClients += $ClientsDomains  ## this appends the Domain data fully to the
            $ClientsDomains = @{}
            $ClientsDomains.Alpha = $firstletter  ## for sorting but may not be necessary
            $ClientsDomains.ClientShortname = $clientshort
            $ClientsDomains.Domains = @()

            }


            ## >>  Per Domain data
            #$ClientsDomains.Points2Dells = $points2Dells
            #$ClientsDomains.Points2DellsRedirectServer = $isRedirectServer
            #$ClientsDomains.id = "3235"
            #$ClientsDomains.LookupTime = (Get-Date).DateTime

            #$ClientsDomains.PreviouslyResolvedIps = @()
            #if($points2Dells){$ClientsDomains.PreviouslyResolvedIps += $DellsIP}
            #else{$ClientsDomains.PreviouslyResolvedIps += $outsideIP}

            $cDomain = @{}
            $cDomain.name = $Domain
            $cDomain.cname = $Domain.replace(".","-")+".alias.TSHprod.com"
            $cDomain.points2Dells = $points2Dells
            $cDomain.points2DellsRedirectServer = $isRedirectServer
            if($Domain -match "*.staged.disenzaone.com"){
                $cDomain.cname = ($Domain -split ("."))[0]+".alias.TSHprod.com"
            }
            $cDomain.ipaddress = $DellsIP
            $ClientsDomains.Domains += $cDomain


            <#THIS PART IS IMPORTANT WHEN YOU ADD THIS CLIENT TO THE JSON OBJECT#>
            ## does the ClientShort match the previous one? if so don't add it to json check the Domain
            #$jsonClients += $ClientsDomains
            ## SET THE CURRENT CLIENTSHORT TO previous
            $previousClientShort = $clientshort
            #######################################################
            $zonename += "`t"+$Domain.replace(".","-")+".alias.TSHprod.com`t$DellsIP`r`n"}



            write-host $newDomainfile -f darkred -b yellow
            $dnsinfoJson | out-file $newDomainfile

            $DomainLog += "`t"+$newDomainfile.replace(".txt","`r`n")

            Sleep 3

        #}

    }

$jsonClients | ConvertTO-Json -Depth 3 | out-file $jsonClientslog  ### this is the source of our Domain store

$clientInstructions | out-file $clientInstructionsFile
$DomainLog + "`r`n`r`n" + $zonename | out-file $DomainLogfile
notepad $DomainLogfile
}

$utility = gc env:computername
EmailMe -subject "Daily DNS resolution" -body "This job is on
Server:              $utility
Location:            E:\git\repos\ds-scripts\Chicago\DNS\ResolveDomainsIntoClientLetter.ps1
Output attachment:   $jsonClientslog
Report Runtime:      $timetaken" -attachment $jsonClientslog
