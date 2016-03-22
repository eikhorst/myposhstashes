function EmailMe ($subject , $body , $attachment ) {   
#[string[]]$to = @("DSE-vintage <DSE-vintage@disenza.com>","pamundson@disenza.com","efrus@disenza.com","molaughlin@disenza.com")
[string[]]$to = @("firep@disenza.com")
    $smtp = "relay-disenza.disenza.com"; $from = "soya.ctyut-a10@disenzaswamy.com"
    if($attachment -ne $null){
        $attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
    }
    else{
        Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
    }
}
clear
$ErrorActionPreference = "SilentlyContinue"
$proxy = "webproxy.disenza.com"


###  Full list of servers
$servers = gc "\\ctyfs-a01s\dsw\mypow\AllServers.txt"
#$servers = @("lk-ETDws-a01.ETDsoya.com","lk-ETDws-a02.ETDsoya.com","lk-ETDut-a01.ETDsoya.com","lk-ETDut-a02.ETDsoya.com")
#$servers = @("tlrielkhubweb01.disenzahost.com","tlrielkhubweb02.disenzahost.com","tlrielkhubweb07.disenzahost.com","tlrielkhubweb08.disenzahost.com")
### for testing:
$servers += @("ctyut-a01")#,"ctyut-a76","ctywsp-a11")
### global vars:
$dt = get-date -Format "yyyyMMdd"
$result = "E:\disenza\scripts\findcerts\"
$fullListLocation = "E:\disenza\scripts\findcerts\$dt.txt"
$archiveDomains = "$($result)_$($dt)\"
#$archiveDomains

clear-content $fullListLocation 

## Gather all Domains configured
$timetaken = measure-command{

## Create holding folder structure
#$alph=@()
#65..90|%{$alph+=[char]$_}
#Create each alpha folder
#foreach($letter in $alph){new-item "$archiveDomains$letter" -type Directory}

    foreach($server in $servers)
    {    
        if((Test-Path "\\$server\logfiles\") -AND ($server -notmatch "ctyws-a67") -AND ($server -notmatch "ctyws-a68")){
            
            $objSites = [adsi]"IIS://$server/W3SVC"
            Write-host  ":::::::$server:::::::::::::::" -f Green 
            
            foreach ($objChild in $objSites.Psbase.children)
            {
                
                if($objChild.KeyType -eq "IIsWebServer"){
                    #Write-host $objChild.Name  # is an id 
                   # Write-host $objChild.ServerComment # is the description                
                    $objChild.ServerState                    
                    $objBindings = $objChild.ServerBindings
                    $objSecBindings = $objChild.SecureBindings
                    foreach($objSB in $objSecBindings){
                    
                        $arrSecBindings = $objSB.Split(':')
                        $secIP = $arrSecBindings[0]
                        $secPort = $arrSecBindings[1]
                        $secSite = $arrSecBindings[2]
                        Write-host $objChild.ServerComment
                        write-host "IP: $secIP"
                        write-host "Port: $secPort"
                        write-host "Site: $secSite"
                    }
                    
                    $strSite = ""
                    foreach($objBinding in $objBindings)
                    {
                       $arrBindings = $objBinding.Split(':')
                        $strPort = $arrBindings[1]
                        $strSite = $arrBindings[2]
                     if($strPort -eq '443'){
                        write-host $strPort
                        Write-host $objChild.ServerComment 
                    }
                    <#
                        $strSite = "";
                        $arrBindings = $objBinding.Split(':')
                        $strPort = $arrBindings[1]
                        $strSite = $arrBindings[2]
                        
                        if(($strSite -notmatch 'ETDsoya.com') -and ($strSite -ne '') ){ #-and ($strSite -notmatch 'disenzaone.com')){ ## >>>>>
                        
                            # Split on "_"; if first in array is OD then use second
                            $Domain = $strSite.ToString()
                            write-host $Domain -f Red -b yellow
                            $ClientShortNameArr = $objChild.ServerComment -Split "`_"
                            $ClientShortName = $ClientShortNameArr[0]
                            if(($ClientShortName -eq "OD") -OR ($ClientShortName -eq "NOTINUSE") -OR ($ClientShortName -eq "NOTLIVE")){
                                $ClientShortName = $ClientShortNameArr[1]
                            }

                              $OutputFileName = $ClientShortName+"`_"+$Domain
                               if(($ClientShortName -ne "SITE") -AND ($ClientShortName -ne "MAINTENENACE") -AND ($ClientShortName -notmatch "TEMP")){
                               
                                #place the file in the right alpha folder
                                #$firstletter = $clientShortName.substring(0,1)
                                
                                #New-Item -Path "$archiveDomains$firstletter\$OutputFileName" -ItemType File                                 
                                
                                #write to a log file
                                $fullList += $OutputFileName+"`r`n"
                                
                                    
                                }
                              
                            } ##..............................
                        } ## >>>>>
                    
                        #>
                    }  ### Efor each Domain binding                                               
                } ## Eif webserver       
            } ## Eforeach site
 
        } ## EIf Server exists       
        
     
    }

}
<#
$fullList | out-file $fullListLocation 
## in order to provide for resolver
$orderedList = gc $fullListLocation | Sort-Object | Get-Unique
$orderedList | out-file $fullListLocation
cp $fullListLocation "\\ctyut-a04\d$\disenza\www\ErrorLogging\LoggingUI\support\Domains\"
$utility = gc env:computername
EmailMe -subject "Finished Gathering Domains" -body "This job is on 
Server:              \\$utility\D$\disenza\scripts\GatherDomains.ps1
Output attachment:   $fullListLocation.Fullname
Report Runtime:      $timetaken
Results: $orderedList
"
#########################################################################################
#>