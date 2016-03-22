.\VMcreation\Get-AzureInitialized.ps1

Function HowTo-SetAzureVMSize{
     [CmdletBinding()]
     param(
         [parameter(Mandatory=$true)]
          [string]$ServiceName,
          [parameter(Mandatory=$false)]
          [ValidateNotNullOrEmpty()]
          [string]$Name=$VM,
          [parameter(Mandatory=$true)]
          [string]$VMSize
     )
     PROCESS{
         Get-AzureVM –ServiceName $ServiceName –Name $Name | 
             Set-AzureVMSize $VMSize | 
             Update-AzureVM
     }
}

$hour = get-date -f "HH"
#$time = get-date -f "HH"

if(($hour -gt 9) -and ($hour -lt 10)){
##morning time turn up my machine
HowTo-SetAzureVMSize –ServiceName "bald-oapz-ju.cloudapp.net" -VM "sushiju-firep" –VMSize "Large"
}

if(($hour -gt 22)){
HowTo-SetAzureVMSize –ServiceName "bald-oapz-ju.cloudapp.net" -VM "sushiju-firep" –VMSize "small"
}



