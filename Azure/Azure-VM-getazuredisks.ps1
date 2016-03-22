.\SetCentral.ps1

Get-AzureDisk | Where-Object { $_.AttachedTo } | Group-Object {$_.Medialink.Host.Split('.')[0]} –NoElement