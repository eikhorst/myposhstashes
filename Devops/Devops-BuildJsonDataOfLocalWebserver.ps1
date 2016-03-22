Import-Module WebAdministration; 
        $jsonSites = @{}
        $serverlinksjson = "c:\temp\serverlinks.json" 
	    clear-content $serverlinksjson
	    write-host "cleared local json file" -f DarkGreen

#        if(!(test-path $serverlinksjson)){ New-Item -ItemType File -Path $serverlinksjson; write-host "new item..." -f DarkGreen } else { clear-content $serverlinksjson write-host "clearing...." -f DarkGreen }
#        if(!(test-path $json2outfile)){ New-Item -ItemType File -Path $json2outfile }else {remove-item $json2outfile}
        
        $sites = Get-ChildItem IIS:\Sites
        
		$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', ${env:computername})
        $RegKey= $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Virtual Machine\\Guest\\Parameters")
        $RmHost = $RegKey.GetValue("HOSTName")
        Write-host "1 $RmHost"
		(get-date -Format 'yyyy-MM-dd hh:mm:ss') + " ${env:ComputerName} 1" >> .\makeazurelinkslog.txt
        #WriteToLog -StringToLog $RmHost -StringToLogColor RED
        $RmPHost = $RegKey.GetValue("PhysicalHostName")
        $sqlxml = $null;
   

        foreach($site in $sites){
        $LoginDomains = ""   ; $Urls = ""                                                                                                            
        if($site -ne $null){
            
            #get the private port here:
           $port= ($site.bindings.Collection | ?{$_.bindingInformation -notmatch ":9999:"} | ?{$_.bindingInformation -notmatch ":80:"} | %{$_.bindingInformation}).TrimStart(':').TrimEnd(':')
           if(($port -notmatch "9999") -and ($port -notmatch "80") -and ($site.Name -ne "CacheInvalidation")){
           
           write-host "2 $port "
           if([string]::IsNullOrWhiteSpace($port)){}
           else{
                #now find all the public port 80 bindings
                $Domain = ($site.bindings.Collection | ?{$_.bindingInformation -match ":80:"} | %{$_.bindingInformation}).Trim('80:')
                write-host "3 $Domain " -f yellow 
                $jsonSite = @{} #$DomainsjsonSite = @{};
                $StrDomain = ""; $LoginDomains
               
                $email = "CN_"+(($site.Name) -split "_")[0]+"@disenza.com";
                $urlcheck = "$($env:computername).disenza.com:$($port)/healthcheck.aspx?product=bds"
               
                    #write-output "$($site.Name) $urlcheck`t$port $($site.Name) webmon`t $Domain $($env:computername)`t$($RmHost)`t$($RmPHost)" | out-file -FilePath $LogFilePath -Append
                    
                    
                    $monitorcheckTitle = $($port)+' '+ $($site.Name)+' ' +" webmon"
                    #$LoginDomains += "<a href=`"http://"+$d+"/commonpages/log41n`" target=""$d"">$d</a><br>"
                    $BRB = "<a href=http://"+$env:computername+":"+$port+"/_jojo/sites/edit/ target=_blank1>BRB</a>"
                    $BRBreload = "<a href=http://"+$env:computername+":"+$port+"/_jojo/config/reload/ target=_blank>Reload</a>"
                    
                    #write-host "$($site.Name)`t$Urls`t$LoginDomains`t$($env:computername)`t$port `t $monitorcheckTitle `t $urlcheck`t$BRB`t$BRBreload`t$($RmHost)`t$email" -f DarkCyan
                    write-host "4 $($site.Name) " -f darkyellow
                    #foreach($Max in $StrDomain){
                    
                        #Create the full list of details
                        
                       
                        $jsonSite.IISComment = $site.Name
                        $jsonSite.Host = $env:COMPUTERNAME
                        $jsonSite.Port = $port
                        $jsonSite.PASMMonitorTitle = $monitorcheckTitle
                        $jsonSite.PASMURLCheck = $urlcheck
                        $jsonSite.BRBreload = "http://"+$env:COMPUTERNAME+":"+$port+"/_jojo/config/reload/"
                        $jsonSite.BRBedit = "http://"+$env:COMPUTERNAME+":"+$port+"/_jojo/sites/edit/"
                        $jsonSite.HVisor = $RmHost
                        $jsonSite.CNDistro = $email
                        $jsonSite.Urls = @(); #$jsonSite.Urls = $url
                        $jsonSite.Logins = @(); #$jsonSite.Logins = $logins
                        if($sqlxml -eq $null){
                            $sqlxmlpath = '\\'+$env:Computername+'\c$\program files\sqlxml 4.0'
                            Test-Path  $sqlxmlpath
                            if(Test-Path $sqlxmlpath){$sqlxml = "Yes"}else{$sqlxml = "No"}                         
                        }
                        $jsonSite.SQLxml = $sqlxml

                        foreach($d in $Domain.Split(' ')){
                            #$url = @{}; $login = @{}
                            $StrDomain += $d + ','
                                if($d -match 'www*'){
                                    $LoginDomains += "<a href='http://$d/commonpages/log41n' target=_blank>wapp Login</a><br /><br />"
                                }
                                if($d -match 'market*'){
                                    $LoginDomains += "<a href='http://$d/commonpages/log41n' target=_blank>mapp Login</a><br /><br />"
                                }
                                write-host "5" $d 
                                $jsonSite.Urls += $d
                                $jsonSite.Logins += "http://$d/commonpages/log41n"
                            #}
                       }
                       $jsonSite.Domains = $StrDomain.TrimEnd(',')
                       write-host "6" $jsonSite.Domains
                        
                        write-host "7" $port -f red
                        if($port -ne $null ){
                            ($jsonSite | convertto-json -Depth 4 ) + "," | out-file $serverlinksjson -append
                        }
                        
                }

            }#end if site is not null
        }#end if site -ne null            
    }#end foreach site