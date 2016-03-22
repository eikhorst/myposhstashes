. E:\disenza\scripts\getweb.configs\fRecurseFoldersMatchFullFileName.ps1 -ExecutionPolicy RemoteSigned -force
. E:\disenza\scripts\getNIprofiles\getNIprofiles.ps1 -ExecutionPolicy RemoteSigned -force

Get-ChildItemRecurse -path "\\ctyfs-a01s.ETDsoya.com\www\" -fileglob *\web.config -levels 3 > \\ctyfs-a01s.ETDsoya.com\dsw\mypow\sAll.web.configs.txt
Get-ChildItemRecurse -path "\\ctyfs-a01r.ETDsoya.com\www\" -fileglob *\web.config -levels 3 > \\ctyfs-a01s.ETDsoya.com\dsw\mypow\rAll.web.configs.txt
Get-ChildItemRecurse -path "\\ctyfs-a01t.ETDsoya.com\www\" -fileglob *\web.config -levels 3 > \\ctyfs-a01s.ETDsoya.com\dsw\mypow\tAll.web.configs.txt
Get-ChildItemRecurse -path "\\ctyut-a03.ETDsoya.com\exe\" -fileglob *.config -levels 3 > \\ctyfs-a01s.ETDsoya.com\dsw\mypow\AllLoader.configs.txt

#region adding configurations within OD locations
$servers = gc "\\ctyfs-a01s\dsw\mypow\AllServers.txt"
$ODTemp = "\\ctyfs-a01s.ETDsoya.com\dsw\mypow\LocalOD.web.configs.txt"
$DTemp = "\\ctyfs-a01s.ETDsoya.com\dsw\mypow\LocalDwww.web.configs.txt"
$ToGrep = "\\ctyfs-a01s.ETDsoya.com\dsw\mypow\OD.web.configs.txt"

Remove-Item $ODTemp; Remove-Item $DTemp; Remove-Item $ToGrep

foreach($server in $servers){
    $ODpath = "\\"+$server + "\d$\OD\"
    $DWWWpath = "\\"+$server + "\d$\disenza\www\"    
    write-host $ODpath -ForegroundColor DarkYellow
    if(Test-Path $ODpath){ Get-ChildItemRecurse -path $ODpath -fileglob *\web.config -levels 3 >> $ODTemp    }
    if(Test-Path $DWWWpath){ Get-ChildItemRecurse -path $DWWWpath -fileglob *\web.config -levels 3 >> $DTemp    }
}

$final = gc "\\ctyfs-a01s.ETDsoya.com\dsw\mypow\LocalOD.web.configs.txt" | Sort-object | Get-unique
$final2 = gc "\\ctyfs-a01s.ETDsoya.com\dsw\mypow\LocalDWWW.web.configs.txt" | Sort-object | Get-unique

$final > $ToGrep
$final2 >> $ToGrep
#end region
