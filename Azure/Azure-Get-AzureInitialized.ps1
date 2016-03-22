<#
(Get-AzureSubscription).SubscriptionName | Sort-Object

(Get-AzureStorageAccount).StorageAccountName | Sort-Object

(Get-AzureService).ServiceName | Sort-Object
#>

#https://bds1atz1lrs.blob.core.windows.net/vhds/bald-oprimzju-primJU-firep-2014-7-15-21-31-3-919-0.vhd
#B_disenza-CentralUS-sushi5755  or B_sushiFork-5755
$subscriptionName = 'B_sushiFork-5755'   
$serviceName = 'bald-oapz-ju'

#bald-oapz-ju  or bald-sushiju
 
# Retrieve with Get-AzureStorageAccount 
$storageAccountName = 'bds1apu2lrs'    


# Enumerate available locations with Get-AzureLocation.  
# Must be the same as your virtual network affinity group. 
#$affinityGroup = 'AG-DSESorryServers' 

# Specify the storage account location to store the newly created VHDs  
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName  
   
# Select the correct subscription (allows multiple subscription support)  
Select-AzureSubscription -SubscriptionName $subscriptionName

