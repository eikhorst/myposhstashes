#cd C:\git\repos\azure\Maintenance\

$servers = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushifig-sfa'} | select -Expand Name | sort
$servers = $servers -join ','
.\GetRemoteServerPortInformation.ps1 -vms $servers
$total = "c:\temp\allsites.txt"; clc $total
$totaldupes = "c:\temp\allsitesdupes.txt"; clc $totaldupes
"`"IISComment`"`,`"Host`"`,`"Port`"`,`"Login`"`,`"PASM-MonitorTitle`"`,`"PASM-URLCheck`"`,`"BRB`"`,`"HVisor`"" | out-file $total -Append
$simpletotal = "c:\temp\simplesites.txt"; clc $simpletotal
"`"IISComment`"`,`"Login`",`"Port`"" | out-file $simpletotal -Append
$simpletotaldupes = "c:\temp\simpletotaldupes.txt"; clc $simpletotaldupes

foreach($s in $servers.split(',')){
    $file = "\\$s\c$\temp\serverlinks.txt"    
    $simplefile = "\\$s\c$\temp\serversimple.txt"    
    if((Test-path $file) -and (Test-path $simplefile)){        
        $regex = "^`"IIS.+$"
        type $file | ?{$_ -notmatch $regex } | out-file $totaldupes -Append  #>> $total
        type $simplefile | ?{$_ -notmatch $regex } |  out-file $simpletotaldupes -Append  #>> $total
    }
    else{
        write-host "$file or $simplefile is inaccessible"
    }
}

#type $total | out-file $total -Append

#copy the local files to the public site
type $totaldupes | sort -Unique | out-file $total -Append
type $simpletotaldupes | sort -Unique | out-file $simpletotal -Append
$destination ="\\sushisftp-01\c$\DSE\www\azurelinks\data\"
copy-item  $total $destination; copy-item  $simpletotal $destination
#fordebuggin local
copy-item  $total C:\git\repos\azurelinks\data\; copy-item  $simpletotal C:\git\repos\azurelinks\data\