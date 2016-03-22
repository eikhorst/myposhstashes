
## Data gets copied to here:  \\sushisftp-01\c$\DSE\www\azurelinks\data 
## Job runs every 4 hours on sushisched-env-01> DSE Reports - MakeAzureLinks
## Powershell Files are here: \\sushisched-env-01\Operations\Scripts\Reports\MakeAzureLinks.ps1

    if($env:COMPUTERNAME -match "sushiju-firep"){
        cd C:\git\repos\azure\Reports\
    }
    else{
        cd f:\operations\scripts\reports\
    }

$timetaken = Measure-Command{    
    #$servers = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushiICE-SID'} | select -Expand Name | sort
    $servers = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -notmatch '(sushiEGG|sushiQQ5|bacon)'} | select -Expand Name | sort -Descending
    $servers = $servers -join ','
    write-host $servers -f DarkMagenta
    .\GetRemoteServerPortInformation.ps1 -vms $servers
    $allsitesjson = "c:\temp\allsites.json"; clc $allsitesjson
    $totaljson =""
    foreach($s in $servers.split(',')){
        $jsonfile = "\\$s\c$\temp\serverlinks.json"
        #(get-item $jsonfile).LastWriteTime
        if((Test-path $jsonfile)){
            if((gc $jsonfile) -ne ""){
               $totaljson += (( gc $jsonfile ) )#| Out-String | convertfrom-json)           
            }
        }         
    }

    write-host $totaljson
    $todaysjson = (get-date -Format yyyy-MM-dd)+"_azurelinks.json"
    ("["+$totaljson.tostring().trimend(',')+"]") | out-file  $allsitesjson
    ("["+$totaljson.tostring().trimend(',')+"]") | out-file  $todaysjson
    #copy the local files to the public site
	if($env:COMPUTERNAME -match "sushiju-firep"){
		$destination ="\\sushisched-env-01\c$\DSE\www\azurelinks\data\allsites.json"
    }
    else{        
		$destination ="C:\DSE\www\azurelinks\data\allsites.json"
    }
    
    ###  copy items out now
    write-host "copying $allsitesjson to $destination"
    copy-item $allsitesjson $destination

}
write-host "Time taken: "
write-host $timetaken
write-host "Updated json file at: "
(get-item $allsitesjson).LastWriteTime


### clean up any left open sessions
Get-PSSession | Remove-PSSession 
