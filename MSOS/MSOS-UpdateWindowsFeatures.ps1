#remove adds
$VM = 'sushiju-ninja.disenza.com'

Get-WindowsFeature -ComputerName $VM | ? -FilterScript {$_.Name -eq 'AD-Domain-Services'} | Uninstall-WindowsFeature -Remove 

Install-WWindowsFeature -Name GPMC -ComputerName $VM -Restart