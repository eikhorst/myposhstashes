$Service = read-host -Prompt "Service Name"
$VM = Read-host -Prompt "VM"
(get-azurevm -ServiceName $Service -Name $VM).Status