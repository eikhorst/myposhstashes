$servers = gc "\\ctyfs-a01s\dsw\mypow\logfiles.txt" 


foreach($server in $servers){
    #$server = "\\"+$server+"\logfiles\"
    Write-host $server    
    
    $iislogfolders = gci $server    
    foreach($logfolder in $iislogfolders){
        $foldersize = (Get-item $logfolder).length
        write-host $server $logfolder $foldersize -ForegroundColor blue
    }
    
}