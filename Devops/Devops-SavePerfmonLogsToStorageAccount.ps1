$subscriptionName = 'B_disenza-CentralUS-STOR-5755'

# Retrieve with Get-AzureStorageAccount
$storageAccountName = 'skiapperfmonlogs'

# Specify the storage account location to store the newly created VHDs
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName

# Select the correct subscription (allows multiple subscription support)
Select-AzureSubscription -SubscriptionName $subscriptionName

Get-AzureSubscription -Current
$keys = read-host -prompt "I need the storage account key"
$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushi(FIG|GUM|HAM|ICE|1st)-(FIL|SQL)'} | select -Expand Name | sort
$myCtx=New-AzureStorageContext skiapperfmonlogs $keys
$azureStorageContainer = 'filesql'
$keep = 24


#write-host $servers -f DarkYellow

foreach($vm in $servers){
$serverpath = "\\"+$vm+"\c$\Perflogs\"
    if(Test-Path $serverpath){
        #backit up
        $files = gci $serverpath

        foreach($file in $files){
            if(!$file.PSIsContainer){
                ## should test if the file is already there before it copies, need to find the check
                $nameblob = $file.Name
                write-host $nameblob -f Cyan
                ## get the blob first if it doesn't exist then push it
                try{
                    $blob = Get-AzureStorageBlob -Blob $nameblob -Container $azureStorageContainer -Context $myCtx -ErrorAction Stop
                }
                catch [Microsoft.WindowsAzure.Commands.Storage.Common.ResourceNotFoundException]
                {
                    # Add logic here to remember that the blob doesn't exist...
                    Write-Host "Blob Not Found, copying"
                    Set-AzureStorageBlobContent -Blob $nameblob -Container $azureStorageContainer -File $file.FullName -Context $myCtx
                }
                catch
                {
                    # Report any other error
                    Write-Error $Error[0].Exception;
                }
            }
        }

        if($files.Count -gt $keep){
            $files | Sort-Object CreationTime| select-object -first ($files.Count - $keep) | Remove-item -force
        }
    }
}

