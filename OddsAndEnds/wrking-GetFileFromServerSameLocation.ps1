$servers = gc @("\\ctyfs-a01s\dsw\mypow\testservers.txt")
$compareloc = "\\ctyfs-a01s\dsw\Misc\compareWeb.config\"

foreach($srv in $servers){   
    $serverconfig = "\\"+$srv+"\C$\Windows\Microsoft.NET\Framework64\v2.0.50727\config\web.config"
    write-host $srv
    $comparespecific = "$($compareloc)$srv.txt"
    write-host $comparespecific
    copy-item $serverconfig -destination $comparespecific -recurse -force
    
}
