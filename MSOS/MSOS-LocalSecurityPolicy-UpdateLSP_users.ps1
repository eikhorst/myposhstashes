
$fileNEW = "E:\disenza\NewODUser.inf"
$iDB = "E:\disenza\LOAAS.sdb"
#$backupdir = "E:\disenza\scripts\getsec\Backups2\"
$date = get-date -format "yyyyMMdd_HHmm"
$newStr = "[Unicode]`r`nUnicode=yes`r`n[Privilege Rights]`r`n##stub##`r`n[Version]`r`nsignature=`"`$CHICAGO`$`"`r`nRevision=1"

$servers = gc "E:\disenza\scripts\working\rest.txt"
#$servers = @("ctyws-a85")#,"ctyws-a26","ctyws-a27","ctyws-a28")

# secedit imports/exports users 
foreach($server in $servers){
# vars reinitialized for every server
#$backupfile = "E:\disenza\scripts\getsec\Backups\"

$file = "d$\disenza\logonasaservice.inf"
$fileNEW = "d$\disenza\NewODUser.inf"
$append = "`\`\"+$server+"`\"
$newuser = "S-1-5-21-2954971464-2892858724-4048379527-1948"
$existing = ""

$file = $append+$file
$fileNEW = $append+$fileNEW

Remove-Item $file; Remove-Item $fileNEW

write-host $file ; write-host $fileNEW ; write-host $iDB

E:
cd E:\disenza\scripts\getCounters

Write-host "Exporting UserRights to $file" -ForegroundColor RED -BackgroundColor Black
### EXPORT THE DATA HERE
.\psexec.exe /acceptEula \\$server secedit /export /cfg $file /areas USER_RIGHTS

## read in inf
$bac = gc $file

#create the backup file
<#$backupfile += $server + ".txt"
$bac | out-file  $backupfile#>

# now update the inf file to add the new user
foreach($line in $bac){
    
    if($line -match 'SeServiceLogonRight*')
    {
        $existing = $line
        if($existing -notlike "*$newuser"){
            $existing += ","+$newuser   ## this adds the new user
        
        #now create the file to be imported
        new-item $fileNEW -type FILE
        $newStr = $newStr -replace "##stub##", $existing
        $newStr | out-file $fileNEW               
Write-host "Writing new UserRights file to $fileNEW" -ForegroundColor RED -BackgroundColor Black
        }
    }    
} 

### NOW IMPORT THIS NEW FILE, but it has to use the local reference
#
$fileNEW = "E:\disenza\NewODUser.inf"
.\psexec.exe /acceptEula \\$server secedit /import /cfg $fileNEW /areas USER_RIGHTS /db $iDB
Write-host "Importing rights to $iDB" -ForegroundColor RED -BackgroundColor Black

#
.\psexec.exe /acceptEula \\$server secedit /configure /areas USER_RIGHTS /db $iDB
Write-host "Configuring security to $iDB" -ForegroundColor RED -BackgroundColor Black

# Export this data again to review
.\psexec.exe /acceptEula \\$server secedit /export /cfg $file /areas USER_RIGHTS
Write-host "RE-Exporting UserRights to $file" -ForegroundColor RED -BackgroundColor Black
#$iDB = $append+$iDB; $fileNEW = 
#Remove-Item $iDB

}