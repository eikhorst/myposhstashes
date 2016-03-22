
# cleanup
# to remove the security templates/sdbs
$servers = Get-Content "\\ctyfs-a01s\dsw\mypow\AllsoyaServers.txt"

$dir = "\d$\disenza\"

E:
cd "E:\disenza\scripts\getCounters"
foreach($server in $servers){

    $removefiles = "\\" + $server + $dir
    $f = get-childitem -path $removefiles -Filter "*.inf"

    if($f.Count -gt 0){
    Write-host "$server`r`n$f"

    cd $removefiles
    #del *.inf, *.sdb
    }
}



