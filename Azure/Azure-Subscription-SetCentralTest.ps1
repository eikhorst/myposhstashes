<#
(Get-AzureSubscription).SubscriptionName | Sort-Object

(Get-AzureStorageAccount).StorageAccountName | Sort-Object

(Get-AzureService).ServiceName | Sort-Object
#>

#Add-AzureAccount

$subscriptionName = 'B_disenza-CentralUS-prim5755'   
$serviceName = 'bald-primju'

# Retrieve with Get-AzureStorageAccount 
$storageAccountName = 'bdsatjump2lrs'    

# Specify the storage account location to store the newly created VHDs  
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName  
   
# Select the correct subscription (allows multiple subscription support)  
Select-AzureSubscription -SubscriptionName $subscriptionName

Get-AzureSubscription -Current

