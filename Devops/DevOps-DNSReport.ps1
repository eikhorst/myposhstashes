function EmailMe ($subject , $body , $attachment ) {   
[string[]]$to = "DSE-Deployment <DSE-deployment@disenzaswamy.com>"
    $smtp = "relay-disenza.disenza.com"; $from = "ut10.soya@disenza.com"
    $attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
}
function GetIP ($ofthis){
	$strText = ping $ofthis -n 1        
    $pattern = "(?<num>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"
    $matched = [regex]::matches($strText, $pattern)
	
	return $matched[0].Value

}
function ServerState ($SiteStatus){
	switch($SiteStatus)
	{
    	1{ "Starting" }
    	2{ "Started"  }
    	3{ "Stopping" }
		4{ "Stopped" }
    	5{ "Pausing" }
    	6{ "Paused" }
    	7{ "Continuing" }
    	default { "Unknown" }	
	}
}

function DNSReport ($attachment, $hostout) {
$outfile = $attachment
$outhost = $hostout
##Get the bindings
$servers = gc "\\ctyfs-a01s\dsw\mypow\AllServers.txt"
$patternShortname = "((?<=^\\\\ctyfs-a01\w{1}\\www\\)|(?<=^\\\\D\:disenza\\www\\)).+(?=\\[\w\d]{4}\\(wapp|mapp))"
$patternFQDN = "\.[^\.]+\.(com|net|info|org)$"
$pattern = "Primary nameserver\: \<strong\>(?<num>[^\<]+)\<\/strong\>"
$patternerrors = "error\.gif"
$patternTTL = "Default TTL\: \<strong\>(?<ttl>[^\<]+)\<\/strong\>" 
$proxy = "webproxy.disenza.com"
$array = @()

foreach($server in $servers)
{
    $objSites = [adsi]"IIS://$server/W3SVC"
    Write-host $server "::Start::"
	$InternalServerIP = GetIP -ofthis $server
	
    foreach ($objChild in $objSites.Psbase.children)
    {
        if($objChild.KeyType -eq "IIsWebServer"){
     Write-host " <-- Start " $objChild.Name.ToString() # is an id 
     Write-host $objChild.ServerComment.ToString() # is the description                
            #$objChild.ServerState
			$strSiteState = ServerState -SiteStatus $objChild.ServerState.ToString()
            $objBindings = $objChild.ServerBindings
			$root = $objChild.Adspath + "/root" # is the root of the website directory
            $site = [adsi]$root
			
			$matchedShortname = [regex]::matches($site.Path, $patternShortname)
	
			$clShortname = $matchedShortname[0].Value
			if(($clShortname -eq $null) -or ($clShortname -eq "")){
				$clShortname = $objChild.ServerComment.ToString().Split('_')[0]
				if(($clShortname -eq $null) -or ($clShortname -eq "")){$clShortname = $objChild.ServerComment.ToString().Split('.')[0]}
			}
            foreach($objBinding in $objBindings)
            {
                $arrBindings = $objBinding.Split(':')
                $strPort = $arrBindings[1]
                $strDomain = $arrBindings[2]
				#$UsesETDDotComDomainFlag = "False"
				$IP = GetIP -ofthis $strDomain
				
				#region  Does the URL point to our Range in Dells or Paris?
				$DellsIPRange = "312.94.12"
				$ParisIPRange = "154.18.168"
				$PointsToDells = $false; $PointsToDellsFlag = "False"
				$PointsToParis = $false; $PointsToParisFlag = "False"
				$PointsSomeWhereElse = $false; $PointsSomeWhereElseFlag = "False"
				
				if($IP -match $DellsIPRange){
					$PointsToDells = $true; $PointsToDellsFlag = "True"	
				}
				if($IP -match $ParisIPRange){
					$PointsToParis = $true; $PointsToParisFlag = "True"	
				}
				
				if(!$PointsToDells -and !$PointsToParis)
				{$PointsSomeWhereElse = $true; $PointsSomeWhereElseFlag = "True"}
				
				#endregion				

				#$RedirectsTo = $strDomain				
				if(($strDomain -match "disenzaone.") -or ($strDomain -match "ETDsoya.") -or ($strDomain -match "disenzahost.")){ 
				#This cuts out testing all of the internal addresses
				    if($strDomain -ne "daviswrightwc.staged.disenzaone.com"){
                	   $strDomain = "[$strDomain]"
                    }
					#$UsesETDDotComDomainFlag = "True"			
				}
                
				if($strDomain -notmatch "\[" ){
				#region Get Other DNS Info

				$matchedFQDN = [regex]::matches($strDomain, $patternFQDN)
				$fqdn = $matchedFQDN[0].Value -replace "^\.",""				
Write-Host "$fqdn	= FQDN"			    
			    $url = "http://www.intodns.com/Domain"
				$DomainHasManyErrors = $false; $DomainHasManyErrorsFlag = "False"
			    #if fqdn is the same as last one then skip this check
				if($prevFQDN -ne $fqdn){
				    $CheckMe = $url -replace "Domain", $fqdn
					
					[net.httpWebRequest] $req = [net.webRequest]::create($CheckMe)
				    $req.Proxy = new-object -typename system.net.webproxy -argumentlist "http://$proxy"
					$req.Method = "GET"; $req.ContentType = "text/html"; $req.Timeout = "5000";			    			    
					[net.httpWebResponse] $res = $req.getResponse();
				    $resst = $res.getResponseStream(); $sr = new-object IO.StreamReader($resst); $webpage = $sr.ReadToEnd(); $res.Close();        
					
					#region Do we manage DNS?
					#check if url is hosted by us
				#Primary nameserver: <strong>bob.ns.cloudflare.com</strong><br />   
## Could update to use resolve-dnsname if using powershell3
				    $matched = [regex]::matches($webpage, $pattern)   
					$matchedTTL = [regex]::matches($webpage, $patternTTL)   
				    write-host $matched[0].Groups[1] -foregroundcolor red			
					$Nameservers = $matched[0].Groups[1].Value			
					$TTL = $matchedTTL[0].Groups[1].Value
					$WeHostDNS = "False"
					if($Nameservers -match "comiccon.net")
					{
						$WeHostDNS = "True"
					}				
					#endregion Do we manage DNS?
					
					#region Anything else we can gleen from IntoDNS?

					$matchedErrors = [regex]::Matches($webpage, $patternerrors)
					
					if($matchedErrors.Count -gt 3)
					{
						Write-Host "$strDomain has a lot of DNS problems" -ForegroundColor DarkMagenta -BackgroundColor Gray
						$DomainHasManyErrors = $true; $DomainHasManyErrorsFlag = "True"
					}
					$prevFQDN = $fqdn
 				}
				#endregion Anything else we can gleen from IntoDNS?								
				#endregion Get Other DNS Info
                
	            
				#region Now put all the info into a temp object that can be added to an array to be later written to a file.
Write-Host "$CheckMe Done" -Foregroundcolor Red				
				
#Server,Client ID,Client Shortname,IIS ID,IIS Name,State,Domain,Redirects To,Internal IP,Port,External IP,TTL,Aliases,Cert Name,Cert Expire,Cert Exp Days,Name Servers				
					$tmpObj = New-Object Object 
		            $tmpObj | add-member -membertype noteproperty -name "Server" -value $server 
					$tmpObj | Add-Member -MemberType NoteProperty -Name "Client ID" -Value $objChild.Name.ToString()
					$tmpObj | Add-Member -MemberType NoteProperty -Name "Client Shortname" -Value $clShortname.ToUpper()			
					$tmpObj | Add-Member -MemberType NoteProperty -Name "IIS Name" -Value $objChild.ServerComment.ToString()
					$tmpObj | Add-Member -MemberType NoteProperty -Name "State" -Value $strSiteState
					$tmpObj | Add-Member -MemberType NoteProperty -Name "Domain" -Value $strDomain					
					$tmpObj | Add-Member -MemberType NoteProperty -Name "Internal IP" -Value $InternalServerIP
					$tmpObj | Add-Member -MemberType NoteProperty -Name "Port" -Value $strPort
					$tmpObj | Add-Member -MemberType NoteProperty -Name "External IP" -Value $IP
					$tmpObj | Add-Member -MemberType NoteProperty -Name "Name Servers" -Value $Nameservers					
					$tmpObj | Add-Member -MemberType NoteProperty -Name "TTL" -Value $TTL										
					$tmpObj | Add-Member -MemberType NoteProperty -Name "comiccon.Net Hosted" -Value $WeHostDNS	
					$tmpObj | Add-Member -MemberType NoteProperty -Name "Points@Dells" -Value $PointsToDellsFlag
					$tmpObj | Add-Member -MemberType NoteProperty -Name "Points@Paris" -Value $PointsToParisFlag					
					$tmpObj | Add-Member -MemberType NoteProperty -Name "PointsElsewhere" -Value $PointsSomeWhereElseFlag				
					$tmpObj | Add-Member -MemberType NoteProperty -Name "ManyDomainErrors" -Value $DomainHasManyErrorsFlag			
					$tmpObj | Add-Member -MemberType NoteProperty -Name "TestingURL" -Value $CheckMe

		            $array +=$tmpObj 	

		            $HostTmp = New-Object Object
                    $HostTmp = @("$($InternalServerIP)`t$($strDomain)")
		            #$HostTmp | add-member -membertype NoteProperty -Name "#Internal IP" -Value $InternalServerIP
		            #$HostTmp | add-member -membertype NoteProperty -Name "#Domain" -Value $strDomain
		            $HostArray += $HostTmp

					$Nameservers =""
				#endregion Now put all the info into a temp object that can be added to an array to be later written to a file.					
				}
            }                     			            

        }
    }    
}
                  
$array | export-csv $outfile -notypeinformation                       
$HostArray | Out-File "E:\disenza\scripts\out\hosts2"

## NOW DEPLOY AN UPDATED HOST FILE TO ALL THE cballey SERVERS

$filteredht = @{}
$hostsfile = "E:\disenza\scripts\out\hosts"; Clear-Content $hostsfile

$HostArray | foreach { $Domain = $_.Split('	')[1]; if(!$filteredht.Contains($Domain)){ if($Domain -ne ""){$filteredht.Add($($Domain),$_.Split('	')[0])} };}
$filteredht.GetEnumerator() | Sort-Object Name | ForEach-Object { "{0}	{1}" -f $_.Value,$_.Name } | add-content $hostsfile

$utils = @("ctyut-a04","ctyut-a07","ctyut-a11","ctyut-a12","ctyut-a13")
#$utils = "ctyut-a02","ctyut-a04"
foreach($util in $utils){    
	#back things up
    Copy-Item -Path "\\$util\c$\windows\system32\drivers\etc\hosts" -Destination "\\$util\c$\windows\system32\drivers\etc\$util`_hosts"
    copy-item -Path $hostsfile -Destination "\\$util\c$\windows\system32\drivers\etc\hosts"
}

}
$dayoftheweek = get-date -uformat %A
$outfile = "E:\disenza\scripts\out\DNSReport_$dayoftheweek.csv"

$utility = gc env:computername
$timetaken = Measure-Command{ DNSReport -attachment $outfile -hostout $outHostfile }
EmailMe -subject "soya DNS Report" -body "This job is on 
Server:              $utility
Location:            E:\disenza\scripts\GetIISsites\DNSReport.ps1
Output attachment:   $outfile
Report Runtime:      $timetaken" -attachment $outfile

