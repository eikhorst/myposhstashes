function EmailMe ($subject, $body, $attachment) {    
[string[]]$to = @("DSE-deployment@disenza.com")
 #[string[]]$to = @("firep@disenza.com")
    $machine = $env:ComputerName+"_DNSChecker@disenza.com"
    $smtp = "internal.disenzahost.com"; $from = $machine
    $attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
}


$proxy = "webproxy.int.comiccon.com"
$Domains = gc("E:\powershell\batch\DNS\Domains.HUR.txt")
#$Domains = @("web2.westlaw.com")
$outfile = "E:\powershell\batch\DNS\AllPings\New\"
$dt = (get-Date).tostring("yyyy_MM_dd_HH")
$outResult = "E:\powershell\batch\DNS\Archive\DNSChanges_"+(get-Date).tostring("yyyyMMddHHssmm")+".txt"
$AllPingsReport = "E:\powershell\batch\DNS\DNSReport_"+(get-Date).tostring("yyyyMMdd")+".txt"
$outTempfile = "E:\powershell\batch\DNS\temp.txt"
$unresolvedfile = "E:\powershell\batch\DNS\unresolved.txt"
[string]$changelog = "";[string]$unresolved = "";
$ErrorActionPreference = "SilentlyContinue"
$MultipleIPLogs = "E:\powershell\batch\DNS\AllPings\DomainsWithMultipleIPs\"
$debug = $false

$time = Measure-Command{    
    foreach($Domain in $Domains)
    {  
            $pingout = $outfile + $Domain + ".txt"                        
            Write-Host $pingout -ForegroundColor White
            $address = $null; $CnameResolution = $null; $MaxNameServer = $null; $MaxNameAdmin = $null; $ARecord = $null; $NSRecord = $null;
            $ARecord = Resolve-DnsName $Domain -Type A 
            $NSRecord = Resolve-DnsName $Domain -Type NS 
            if($ARecord -ne $null)
                { 
                $address = $ARecord.Address
                    if($address -match "")
                        {
                        if($address -match ""){$address = $ARecord[0].IPAddress}
                        if($address -match ""){$address = $ARecord[0].Address}        
                        if($address -match ""){$address = $ARecord[0].IP4Address}        
                        if($address -match ""){$address = $ARecord.IP4Address}        
                        if($address.Count -gt 1){$address = $address[0]}
                        Write-host $address -ForegroundColor DarkCyan
                        }
                    if(($Domain -match "www") -and ($NSRecord -ne $null)){
                        #$MaxPrimaryServer = $NSRecord.PrimaryServer
                        $MaxNameAdmin = $NSRecord.NameAdministrator
                        $CnameResolution = $NSRecord.NameHost
                        #Write-host $MaxPrimaryServer -ForegroundColor Yellow
                        Write-Host $MaxNameAdmin -ForegroundColor Yellow

                        if($Domain -notcontains "www"){
                        $MaxServer = $NSRecord.Server
                        $MaxNameServer += @($NSRecord[0].NameHost) -join " " 
                        Write-Host $MaxServer -ForegroundColor DarkGreen
                        }
                    }

                
            ##Setting the new hash for all resolution data:
            $tmpNewCheck = New-Object Object 
            $tmpNewCheck | add-member -membertype noteproperty -name "Domain" -value $Domain             
            $tmpNewCheck | add-member -membertype noteproperty -name "arecord" -value $address
            $tmpNewCheck | add-member -membertype noteproperty -name "cname" -value $CnameResolution
            $tmpNewCheck | add-member -membertype noteproperty -name "nameservers" -value $MaxNameServer
            $tmpNewCheck | add-member -membertype noteproperty -name "nameadministrator" -value $MaxNameAdmin
            #$arrCurrentCheck = $tmpNewCheck 

            $newping = $tmpNewCheck
            ## this is the default - no change detected
            $result = "DNS did not change for $Domain : $address"   
            if($debug -eq $true){ write-host $oldping[0].arecord -ForegroundColor Cyan; 
                                    write-host $newping[0].arecord -ForegroundColor DarkCyan}
            ##Check if the path exists and compare values otherwise create it and do the notification accordingly
            if(test-path $pingout){        
                #OLD PING EXISTS NOW CHECK PREVIOUS TO CURRENT CHECK
                $oldping = Import-Csv $pingout
                #write-host $oldping -ForegroundColor Yellow -BackgroundColor Black                
                #----------------
                # match on exactness = no change; if different match on first 3 octet
                #----------------                
                if( $oldping.arecord -eq $newping.arecord ){            
                    Write-host "OLD and NEW Pings matched exactly - NO CHANGE" -ForegroundColor DarkGreen -BackgroundColor Green                    
                }
                else
                {
                    Write-host "OLD and NEW did not match - CHANGE detected" -ForegroundColor DarkRed -BackgroundColor Red
                    $CheckMultiFile = $MultipleIPLogs + $Domain + ".txt"

                    $result = "`r`n $Domain CHANGED FROM: " + $oldping[0].arecord + " TO: " + $newping[0].arecord
                                            
                    if(test-path $CheckMultiFile){ # now do more testing if the IP exists in this location
                        $CheckMultiContents = GC $CheckMultiFile
                        if(($CheckMultiContents.Contains($newping[0].arecord)) -or ($newping.arecord -eq "")){
                            $result = ""
                        }
                        else{ $newping[0].arecord | Out-File $CheckMultiFile -Append -Encoding ASCII }                                                                             
                    }
                    else{
                        if($newping[0].arecord -ne ""){
                        New-Item -ItemType "file" -Path $CheckMultiFile
                        $newping[0].arecord | Out-File $CheckMultiFile -Append -Encoding ASCII
                        }
                    }                
                    if($oldping.arecord -match "312.94.12."){  ## to cut down on the notifications that are not pointed to Dells anyway
                        $changelog += $result                    
                    }                                                 
	            }
            }
            else{ 
                if($newping -ne $null){
                New-Item $pingout -type "file"                         
                $result = "Found new Domain: $Domain - $newping[0].arecord"       
                $changelog += "`r`n" + $result
                }
                
            }     
            $result | out-file $outResult -append    
            $newping | Export-Csv $pingout -NoTypeInformation
            $newping | Export-Csv $AllPingsReport -NoTypeInformation 
            
        }       #end if check if arecord is null 
    }
}



if($unresolved -ne ""){$unresolved| out-file $unresolvedfile}
if($changelog -ne ""){
EmailMe -subject "DNS Check - $dt" -body "$changelog `r`n`r`n DNSChecker ran for: $time" -attachment $outResult
(get-Date).tostring("yyyyMMddHHssmm") >> "E:\today\changelog.txt"
$changelog >> "E:\today\changelog.txt"
}


    