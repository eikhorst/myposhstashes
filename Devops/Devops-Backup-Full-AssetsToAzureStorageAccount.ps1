## cd into the directory where this file is:
# cd c:\oni\exe\Clienta\MonthlyBackups\
. .\devops-scheduledbackups.ps1 -ExecutionPolicy RemoteSigned -force

	$smtp = "smtp.disenza.com"
    $to = "DSE-Deployment@disenza.com";
    $from = "ClientaMonthlyBackups@disenza.com"

$TempBackup = "E:\Temp\ClientAMonthly"
if(!(Test-Path $TempBackup)){ New-item -ItemType Directory -Path $TempBackup -Force }

$timetaken = measure-command{

GetFilePath -webserver "sushiice-dim-01" -Domain www.Clienta.com -tempBackupPath E:\temp\ -sqlSrvBackupLocal M:\Backups\ -sqlSrvBackupShare1 \\sushiice-sql-01\backups\sushiICE-SQL-01\Clienta_68L1\FULL\ -sqlSrvBackupShare2 \\sushiice-sql-02\backups\sushiICE-SQL-02\Clienta_68L1\FULL\ -finalBackupPath $TempBackup
#GetWebConfig -rootPath $sitePath -filepath $filepath -siteDomain $Domain -tempBackupPath $tempBackupPath -sqlSrvBackupLocal $sqlSrvBackupLocal -sqlSrvBackupShare $sqlSrvBackupShare -finalBackupPath $finalBackupPath

$date = Get-Date -format yyyy-MM-dd
$file = "www.Clienta.com_$($date).7z"
$todaysBackup = $TempBackup+"\www.Clienta.com_$($date).7z"
$status = Test-path $todaysBackup

}
        $subject = "Storing monthly backup for ClientA Succeeded."
        if($status){$body = "`tElapsed Time:`n" + $timetaken + "`n Latest file is here: $($todaysBackup)"}
        else{
        $body = "`tElapsed Time:" + $timetaken + "`n Backup was not founE: $($todaysBackup)"
        }

        Send-MailMessage –From $from –To $to –Subject "$subject" –Body "$body" –SmtpServer $smtp



##########################
##  now stansfer the backup to blob storage
###########################

$subscriptionName = 'B_disenza-CentralUS-STOR-5755'

# Retrieve with Get-AzureStorageAccount
$storageAccountName = 'skiapmbrown0109'

# Specify the storage account location to store the newly created VHDs
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName

# Select the correct subscription (allows multiple subscription support)
Select-AzureSubscription -SubscriptionName $subscriptionName
Get-AzureSubscription -Current

#$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushi(FIG|GUM|HAM|ICE|1st)-(FIL|SQL)'} | select -Expand Name | sort
$myCtx=New-AzureStorageContext skiapmbrown0109 GVj/H/SoCCrr4kzf4hNLK5Iw62fhKdg57TbNgCjSCdycr/JAmmbQO3uHcnDYOuzjw2zaFY5jX0tJPOg3W6ABVA==
$azureStorageContainer = 'backups'

#$todaysBackup = (gci $TempBackup | Sort-Object CreationTime -Descending)[0]

    if(Test-Path $todaysBackup){
        #backit up to blob

        $nameblob = $filename #($todaysBackup -split ('\'))[2]

        ## get the blob first if it doesn't exist then push it
        #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  start refactoring the rest of this tomorrow, test the backup, move email after this part
        try{
            $blob = Get-AzureStorageBlob -Blob $nameblob -Container $azureStorageContainer -Context $myCtx -ErrorAction Stop
        }
        catch [Microsoft.WindowsAzure.Commands.Storage.Common.ResourceNotFoundException]
        {
            # Add logic here to remember that the blob doesn't exist...
            Write-Host "Blob Not Found, copying"
            Set-AzureStorageBlobContent -Blob $nameblob -Container $azureStorageContainer -File $todaysBackup -Context $myCtx
        }
        catch
        {
            # Report any other error
            Write-Error $Error[0].Exception;
        }

        if($files.Count -gt $keep){
            $files | Sort-Object CreationTime| select-object -first ($files.Count - $keep) | Remove-item -force
        }
    }

