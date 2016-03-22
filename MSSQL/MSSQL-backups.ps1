 $sqlSrvBackupShare1 = "\\sushiice-sql-01\backups\sushiICE-SQL-01\Clienta_68L1\FULL"
 $sqlSrvBackupShare2 = "\\sushiice-sql-02\backups\sushiICE-SQL-02\Clienta_68L1\FULL"
 $bak1 = (gci $sqlSrvBackupShare1) | Sort-Object CreationTime -Descending #
 $bak2 = (gci $sqlSrvBackupShare2) | Sort-Object CreationTime -Descending #
  
 if($bak1[0].CreationTime -gt $bak2[0].CreationTime){
    $backthisup = $bak1[0]
 }
 else{
    $backthisup = $bak2[0]
 }


$backthisup.FullName
 			$copydb = $backthisup.FullName			
			#if(Test-Path $copydb){
$newfolder = "C:\temp\backups\Clienta"
			$pathDB = Join-Path $newfolder -childpath "DB"
write-host $pathDB
			New-Item $pathDB -type directory
write-host "copying $copydb to $pathDB" -f red
			copy-item $copydb $pathDB -recurse
			Remove-Item $copydb -force