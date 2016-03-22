###  Install something on a subset of servers provided in a file.
$timetaken = Measure-Command{
    #to filter:
    cd C:\git\repos\azure\Maintenance\
    #$servers = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushiFIG-SFC'} | select -Expand Name | sort
    
    $servers = gc .\ServerSetup\ServersNeedingSqlXMLInstall.txt
    $servers = $servers -join ','
                
    foreach($s in $servers.split(',')){
    
        if((Test-path ("\\"+$s+"\c$\program files\sqlxml 4.0\")) -OR (Test-path ("\\"+$s+"\c$\program files (x86)\sqlxml 4.0\"))) {
            
            write-host "$env:COMPUTERNAME Sqlxml4.0 is installed" -f greens
        }
        else
        {
            write-host "$env:COMPUTERNAME Sqlxml4.0 needs installation" -f red
            .\install-sqlxml.ps1 -vms $s             
        }

    }
    
}

write-host ("Script ran for: " + $timetaken  + "on all webservers: " + $servers )