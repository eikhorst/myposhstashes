Select-AzureSubscription D_disenza-Redirects-Prod-5755
 
$service = 'TestingCS'
$location = 'West US'
 
## Cloud Service must already exist 
New-AzureService -ServiceName $service -Location $location
 
## Add Certificate to the store on the cloud service (.cer or .pfx with -Password)
Add-AzureCertificate -CertToDeploy 'E:User-DatadevelopmentAzure Samplesmlwdevcert.cer' -ServiceName $service
 
## Create a certificate in the users home directory
$sshkey = New-AzureSSHKey -PublicKey -Fingerprint D7BECD4D63EBAF86023BB4F1A5FBF5C2C924902A -Path '/home/mwasham/.ssh/authorized_keys'
 
New-AzureVMConfig -ImageName 'CANDSECAL__Canonical-Ubuntu-12-04-amd64-server-20120528.1.3-en-us-30GB.vhd' -InstanceSize 'Small' -Name 'linuxwithcert' |
	Add-AzureProvisioningConfig -Linux -LinuxUser 'mwasham' -Password 'somepass@1' -SSHPublicKeys $sshKey |
	New-AzureVM -ServiceName $service