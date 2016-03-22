#$vm1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $m.diskSize1 -DiskLabel 'Scratch' -LUN 0


#cd ..\Deployment
#.\SetCentral.ps1  # sets the central subscription

$vm = Get-AzureVM "bald-sushisftp" -Name "sushisftp-01"

##  Set the vm above and uncomment out the line below to update the VM
# | Set-AzureVMSize –InstanceSize "Standard_D2"
# | New-AzureDataDisk -CreateNew -DiskSizeInGB 500 -DiskLabel More -LUN 2
Set-AzureStorageAccount skiapu2lrs

$vm | Remove-AzureDataDisk -LUN 3 -DeleteVHD | Update-AzureVM

Set-AzureStorageAccount skiapu5lrs
$vm | Add-AzureDataDisk -CreateNew -DiskSizeInGB 500 -DiskLabel TumpOver -LUN 3 | Update-AzureVM
