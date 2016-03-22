function EmailMe ($subject, $body, $attachment) {
   #[string[]]$to = @("DSE-deployment@disenza.com")
   [string[]]$to = @("firep@disenza.com")
   $machine = $env:ComputerName+"_DSELIVE_DNSChecker@disenza.com"
   $smtp = "internal.disenzahost.com"; $from = $machine
   if($attachment -ne $null){
    $attachment | Send-MailMessage -From $from -To $to -Subject $subject -Body "$body" -SmtpServer $smtp
    }else{
        Send-MailMessage -From $from -To $to -Subject $subject -Body "$body" -SmtpServer $smtp
    }
}


$proxy = "myproxy.com"
$httppathSource = gc("E:\disenza\scripts\out\domains\Domains.txt")
#testing here:
#$httppathSource = @('disenza_www.disenza.com','DSE_domain.com','Google_m.google.com')
$outfile = "E:\powershell\batch\DNS\DSELIVE\AllPings\"
$dt = (get-Date).tostring("yyyy_MM_dd_HH")
$outResult = "E:\powershell\batch\DNS\DSELIVE\Archive\DNSChanges_"+(get-Date).tostring("yyyyMMddHHssmm")+".txt"
$AllPingsReport = "E:\powershell\batch\DNS\DSELIVE\FullDnsReport_"+(get-Date).tostring("yyyyMMdd")+".txt"
#$outTempfile = "E:\powershell\batch\DNS\temp.txt"
$unresolvedfile = "E:\powershell\batch\DNS\DSELIVE\unresolved.txt"
[string]$changelog = "";[string]$unresolved = "";; [string]$incidentmessage = ""
#$ErrorActionPreference = "SilentlyContinue"
$MultipleIPLogs = "E:\powershell\batch\DNS\DSELIVE\AllPings\DomainsWithMultipleIPs\"
$debug = $true; $incidentoccurred = $false
$SoyaIPpattern = "123\.45\.67\.\d{1,3}"
$RedirectServerIP = "123\.45\.67\.5\b"
$VegasIPpattern = "84\.18\.168\.\d{1,3}"
$newRedirIP = "23.100.43.208"




$time = Measure-Command{
    foreach($clientShortDomain in $httppathSource){
    if(($clientShortDomain -ne '') -and ($clientShortDomain -ne $null) -and ($clientShortDomain -notcontains " ") -and ($clientShortDomain -inotcontains "temp")){ #-and ($i -lt 10)){
    write-host $clientShortDomain -f red

    $points2Dells = $false; $isRedirectServer = $false; $DellsIP = $null

    $clientshort = ($clientShortDomain -split "`_")[0]
    $Domain = ($clientShortDomain -split "`_")[1] #-replace ".txt",""

    $pingout = $outfile + $clientShortDomain + ".txt"
    Write-Host $pingout -ForegroundColor White
    $address = $null; $CnameResolution = $null; $MaxNameServer = $null; $MaxNameAdmin = $null; $ARecord = $null; $NSRecord = $null;
    $dnsinfoJson = ($plain = Resolve-DnsName $Domain.ToString() -QuickTimeout) | ConvertTo-Json
    $dnsinfoPS = $dnsinfoJson | ConvertFrom-Json
    #$ARecord = Resolve-DnsName $Domain
    write-host $($dnsinfoPS.Type -match '5') -f green -b white #######################  Type 5 is cname
    ## must check ARecord for presence of CNAME type or else resolutions don't work.
    write-host $dnsinfoJson.count -f green -b white
    if($dnsinfoPS.Type -match '5'){
        ## now do all the CNAME STUFF
        $address = $plain.NameHost
        write-host $address -f green -b white
    }
    elseif($dnsinfoPS.Type -match '1'){
        $address = $plain.IPAddress
    }

    if($plain -ne $null)
    {
        #$address = $ARecord.Address
        #write-host $ARecord.NameHost -f green -b red  #######################
        if(($address -eq $null) -and ($address.Length -lt 0))  # now check i the address was not found, b/c if it was set, it had cname so no need to go further  # if it was not set, then this must be an arecord, so figure out if it's pointing to TR.
        {
            if($dnsinfoPS.IPAddress -ne $null){
                $DellsIP = [regex]::matches($dnsinfoPS.IPAddress, $DellssoyaIPpattern)
                if($DellsIP -eq $null){$DellsIP =[regex]::matches($dnsinfoPS.IP4Address, $DellssoyaIPpattern)}
                write-host "1234" -f DarkRed -b white  #######################
            }
            if($DellsIP -eq $null){
                if($plain.IPAddress -eq $null){$DellsIP = $plain.IPAddress}
                if($DellsIP -eq $null){$DellsIP = $plain.IP4Address}
                write-host "567" -f DarkRed -b white   #######################
            }
            $address = $DellsIP
            #Write-host "$address 1" -ForegroundColor DarkCyan
        }
        if($address -eq $null){ ## still an address is empty then it must be a www Domain?
            $NSRecord = Resolve-DnsName $Domain -Type NS
            if(($Domain -match "www") -and ($NSRecord -ne $null)){
                #$MaxPrimaryServer = $NSRecord.PrimaryServer
                $MaxNameAdmin = $NSRecord.NameAdministrator
                $CnameResolution = $NSRecord.NameHost
                #Write-host $MaxPrimaryServer -ForegroundColor Yellow
               # Write-Host $MaxNameAdmin -ForegroundColor Yellow  #######################
               # Write-host "$address 2" -ForegroundColor DarkCyan  #######################
                if($Domain -notcontains "www"){
                    $MaxServer = $NSRecord.Server
                    $MaxNameServer += @($NSRecord[0].NameHost) -join " "
                    Write-Host $MaxServer -ForegroundColor DarkGreen  #######################
                }
            }
        }

        $newping = $clientshort+", "+$Domain+", "+$address+", "+$MaxNameAdmin+", "+$MaxNameServer  ### saving less
        #Write-host "$newping ::dnsinfops" -ForegroundColor Yellow -b DarkMagenta  #######################
        ## this is the default - no change detected
        $result = "DNS did not change for $Domain : $address"
        if($debug -eq $true){
            write-host ($oldping -eq $newping) -ForegroundColor Yellow -b darkgray;
            #write-host $newping -ForegroundColor Yellow
        }
        ##Check if the path exists and compare values otherwise create it and do the notification accordingly
        if(test-path $pingout){
            #OLD PING EXISTS NOW CHECK PREVIOUS TO CURRENT CHECK
            $oldping = gc $pingout
            #write-host $oldping -ForegroundColor Yellow -BackgroundColor Black
            #----------------
            # match on exactness = no change; if different match on first 3 octet
            #----------------
            if( $oldping -eq $newping ){
                Write-host "OLD and NEW Pings matched exactly - NO CHANGE" -ForegroundColor DarkGreen -BackgroundColor Green
            }
            else
            {
                Write-host "OLD and NEW did not match - CHANGE detected" -ForegroundColor DarkRed -BackgroundColor Red
                $CheckMultiFile = $MultipleIPLogs + $clientShortDomain + ".txt"

                $result = "`r`n $Domain CHANGED FROM: " + $oldping + " TO: " + $newping
                <#
                if(test-path $CheckMultiFile){ # now do more testing if the IP exists in this location
                    $CheckMultiContents = GC $CheckMultiFile
                    if(($CheckMultiContents.Contains($newping)) -or ($newping -eq "")){
                        $result = ""
                    }
                    else{ $newping > $CheckMultiFile }# -Append -Encoding ASCII }
                }
                else{
                    if($newping -ne ""){
                        New-Item -ItemType "file" -Path $CheckMultiFile
                        $newping | Out-File $CheckMultiFile -Append -Encoding ASCII
                    }
                }                #>

                $wasPointedAtTR = $null
                $olddata = $oldping -split ","

                $wasPointedAtTR=[regex]::matches($oldping[2], $DellssoyaIPpattern)
                if($wasPointedAtTR -eq $null){
                    $wasPointedAtTR=[regex]::matches($oldping[2], $ParisIPpattern)
                }
                if($wasPointedAtTR -ne $null){  ## to cut down on the notifications that are not pointed to Dells anyway
                    $changelog += $result
                }
            }
        }
        else{
            if($newping -ne $null){
                New-Item $pingout -type "file"
                $result = "Found new Domain: $newping "
                $changelog += "`t`r`n" + $result
            }
        }
        #write-host "$changelog " -f yellow  ###################
        $result | out-file $outResult -append
        $newping > $pingout # -NoTypeInformation
        $newping | Export-Csv $AllPingsReport -NoTypeInformation -append -force

        }       #end if check if arecord is null
        else {
            $incidentmessage += "`t`r`nPowershell cmdlet returned null::   Resolve-DnsName $Domain Try This::  Ping -n 1 $Domain "
            $incidentoccurred = $true
        }
        } ## if client shortname is replace
        else{
            $BadClientShortnames += $clientShortDomain + "`r`n"
        }
        }## foreach
        }## Time measure
        #if($unresolved -ne ""){$unresolved| out-file $unresolvedfile}
        if($changelog -ne ""){
            EmailMe -subject "DNS Check - $dt" -body "DNSChecker ran for: $time `r`n $BadClientShortnames `r`n  $changelog " -attachment $outResult
            (get-Date).ToString("yyyyMMddHHssmm")>>"E:\today\changeTOTSHprodlog.txt"
            $changelog>>"E:\today\changeTOTSHprodlog.txt"
        }
        if($incidentoccurred){
            EmailMe -subject "Unresolved Domains-$dt" -body "$incidentmessage"
        }


