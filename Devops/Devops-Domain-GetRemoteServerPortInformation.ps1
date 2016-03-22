#New-PSSession -computername sushiegg-sab-01
#for testing:
#$vms = @('')
Param(
[Parameter(Mandatory=$True,Position=0)][string]$vms #,
#[Parameter(Mandatory=$True,Position=1)][string]$cred
)
#read-host -assecurestring | convertfrom-securestring | out-file C:\temp\dtss.txt
<#
if($env:COMPUTERNAME -match "sushiju-firep"){
$username = "disenza\da-firep"
$password = cat c:\temp\dtss.txt | ConvertTo-SecureString
}else{
$username = "disenza\svcAutomation"
$password = cat dtss.txt | ConvertTo-SecureString
}#>

#$ErrorActionPreference = "SilentlyContinue"
#$dtcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
#$cred = $dtcred
$vm2s = ($vms -split ',')

foreach($vm in $vm2s){
$testpath = '\\'+$vm+'\c$\temp\serverlinks.json'
#$serverlinksjson = '\\'+$vm+'\c$\temp\serverlinks.json'
#New-Item -ItemType File -Path $serverlinksjson -Force;

$s1 = New-PSSession -ComputerName $vm #-Credential $cred # -UseSSL
    #if(Test-Path $logpath){
        #$s = New-PSSession -ComputerName $vm 
        write-host $vm -f DarkCyan
		#Enter-PSSession -Session $s
    $command = {         
		Write-Host '!!!' -f DarkMagenta
        Import-Module WebAdministration; 
        $jsonSites = @{}
    
        $serverlinksjson = "\\"+$vm+"\c$\temp\serverlinks.json"
        
        $sites = Get-ChildItem IIS:\Sites
        $sites = Get-ChildItem IIS:\Sites # same line as before doing this once has some problems and we were missing lots of data.
        ## it was for the #""
        
		$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', ${env:computername})
        $RegKey= $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Virtual Machine\\Guest\\Parameters")
        $RmHost = $RegKey.GetValue("HOSTName")
        Write-host "1 $RmHost"
		#(get-date -Format 'yyyy-MM-dd hh:mm:ss') + " ${env:ComputerName} 1" >> f:\operations\scripts\reports\log.txt
        #WriteToLog -StringToLog $RmHost -StringToLogColor RED
        $RmPHost = $RegKey.GetValue("PhysicalHostName")

        #test this
        # $sites | ?{$_ -ne $null } | %{ $_.bindings.Collection | %{ $_.bindinginformation; $_.bindinginformation -notmatch "(:80:|:9999:|\*)" ; } }
        write-host $sites.Count -f Blue -b Yellow

        $sqlxml = $null;
   
        if($sites.Count -gt 0){
        New-Item -ItemType File -Path "c:\temp\serverlinks.json" -Force;
                            
            foreach($site in $sites){
        $LoginDomains = ""   ; $Urls = ""                                                                                                            
        if($site -ne $null){
            
            #get the private port here:
           $port= ($site.bindings.Collection | ?{$_.bindingInformation -notmatch ":9999:"} | ?{$_.bindingInformation -notmatch ":80:"} | %{$_.bindingInformation}).TrimStart(':').TrimEnd(':')
           if(($port -notmatch "(9999|^80$)") -and ($site.Name -ne "CacheInvalidation")){
           
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
                    $BRB = "<a href=http://"+$env:computername+":"+$port+"/_jojo/sites/edit/ target=_blank1>BRB</a>"
                    $BRBreload = "<a href=http://"+$env:computername+":"+$port+"/_jojo/config/reload/ target=_blank>Reload</a>"
                    
 #write-host "$($site.Name)`t$Urls`t$LoginDomains`t$($env:computername)`t$port `t $monitorcheckTitle `t $urlcheck`t$BRB`t$BRBreload`t$($RmHost)`t$email" -f DarkCyan
                    write-host "4 $($site.Name) " -f darkyellow
                    
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
                            $sqlxmlpath = '\\'+$env:Computername+'\'+$env:ProgramFiles+'\sqlxml 4.0'
                            Test-Path  $sqlxmlpath
                            if(Test-Path $sqlxmlpath){$sqlxml = "Yes"}else{$sqlxml = "No"; $sqlxmlpath = '\\'+$env:Computername+'\'+${env:ProgramFiles(x86)}+'\sqlxml 4.0'
                                if(test-path $sqlxmlpath){$sqlxml = "Yes"}
                            }                         
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
                        if($jsonSite -ne $null ){
							($jsonSite | convertto-json -Depth 4 ) + "," | out-file c:\temp\serverlinks.json -append                            
                        }
                        
                }

            }#end if site is not null
        }#end if site -ne null            
    }#end foreach site
    }# end if there are sites

    }#end command
    $lastwrite = (get-item $testpath).LastWriteTime
    write-host $testpath  "  " $lastwrite
   
   
#   Exit-PSSession

   #}#End test connection

invoke-command -Session $s1 -scriptblock $command -ThrottleLimit 5

#   Get-PSSession | Remove-PSSession
}#End foreach VM


