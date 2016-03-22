## this gets all your subscriptions:
# (Get-azuresubscription).SubscriptionName | sort > C:\temp\subscriptions.txt

$Subs = gc C:\temp\subscriptions.txt 
foreach($sub in $Subs){

$subname = $sub  #Read-host -Prompt "Subscription Name"

#$storagename = Read-host -Prompt "Storage Name"

Set-AzureSubscription -SubscriptionName $subname #-CurrentStorageAccountName $storagename

Select-AzureSubscription -SubscriptionName $subname

#$subname | out-file c:\temp\VMsStatus.txt -append
Get-AzureService | Get-AzureVM | FormprimTable –auto $subname,"ServiceName","Name","InstanceStatus" | out-file c:\temp\VMsStatus.txt -append


}

