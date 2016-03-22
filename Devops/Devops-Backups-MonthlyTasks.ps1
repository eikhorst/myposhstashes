. E:\disenza\scripts\StoringBackups\devops-scheduledbackups.ps1 -ExecutionPolicy RemoteSigned -force

    $smtp = "relay-disenza.disenza.com"
    $to = "DSE-Deployment@disenzaswamy.com"; 
    $from = "$($env:Computername)@disenza.com"
    
$timetaken = measure-command{
GetFilePath -webserver ctyws-a69.ETDsoya.com -Domain www.clienta.com -tempBackupPath E:\disenza\scripts\StoringBackups\temp\ -sqlSrvBackupLocal E:\Backups\ -sqlSrvBackupShare \\ctysql-a14r\backups\ -finalBackupPath \\prod-soya.disenza.com\Data$\MonthlyArchives\clienta\

$date = Get-Date -format yyyy-MM-dd    
$todaysBackup = "\\prod-soya.disenza.com\Data$\MonthlyArchives\clienta\www.clienta.com_$($date).7z"
$status = Test-path $todaysBackup

}
        $subject = "Storing monthly backup for Clienta."
        if($status){$body = "`tElapsed Time:`n" + $timetaken + "`n Latest file is here: $($todaysBackup)"}
        else{
        $body = "`tElapsed Time:" + $timetaken + "`n Backup was not founE: $($todaysBackup)"
        }
        
        Send-MailMessage –From $from –To $to –Subject "$subject" –Body "$body" –SmtpServer $smtp
        
        