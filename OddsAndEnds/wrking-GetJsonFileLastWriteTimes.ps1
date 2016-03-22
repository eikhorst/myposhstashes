$vms = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -notmatch '(sushiEGG|sushiQQ5|bacon)'} | select -Expand Name | sort -Descending
new-item -ItemType file c:\temp\latestazurelinks.txt -Force
foreach($vm in $vms){    
    $testthis = '\\'+$vm+'\c$\temp\serverlinks.json'
    $testthis +" "+ (get-item $testthis).LastWriteTime | FL ##|out-file c:\temp\latestazurelinks.txt -Append
}


cat c:\temp\latestazurelinks.txt