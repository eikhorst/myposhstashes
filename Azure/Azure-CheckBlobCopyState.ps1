 #Remove-AzureSubscription ## to remove the current context of azurepowershell
 $subscription = "B_baconFork-5755"
 $storageaccountname = "bdsbpeggfillrs"
 set-azuresubscription -SubscriptionName $subscription -CurrentStorageAccountName $storageaccountname
 Select-azuresubscription -Default -SubscriptionName $subscription



Get-AzureStorageBlobCopyState -container vhds -blob bald-sushiEGG-sushiEGG-FIL-02-2014-7-27-21-46-40-591-0.vhd

Get-AzureStorageBlobCopyState -container vhds -blob bald-sushiEGG-sushiEGG-FIL-02-2014-7-27-21-46-40-591-1.vhd

Get-AzureStorageBlobCopyState -container vhds -blob bald-sushiEGG-sushiEGG-FIL-02-2014-7-27-21-46-40-591-2.vhd