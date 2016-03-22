

Set-AzureAvailabilitySet -AvailabilitySetName AS-ADMIN -VM $MyVM

#To update, you get your VM with Get-AzureVM and then you pipe to set the Availability Set and Update the VM.

Get-AzureVM -ServiceName bald-oapz-ju -Name sushiju-firep | Set-AzureAvailabilitySet -AvailabilitySetName AS-ADMIN | Update-AzureVM

#To update all the VM’s in a cloud service, which is what I did, you do this…

Get-AzureService -ServiceName bald-oapz-ju | Get-AzureVM | Set-AzureAvailabilitySet -AvailabilitySetName AS-ADMIN | Update-AzureVM

#It will go through each VM one by one and do the update.  Then you don’t have to babysit in the portal.
