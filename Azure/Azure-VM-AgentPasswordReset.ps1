$password = "soya@disenza2!@#"
Get-AzureVM -ServiceName bald-sushisftp -Name sushisftp-01 | Set-AzureVMAccessExtension -UserName locadmin -Password $password | Update-AzureVM