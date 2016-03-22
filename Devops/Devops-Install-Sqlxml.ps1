Param(
[Parameter(Mandatory=$True,Position=0)][string]$vms #,
#[Parameter(Mandatory=$True,Position=1)][string]$scriptsfolder
)
#$vm = @('')#,sushiegg-sbc-01.disenza.com,sushiegg-scd-01.disenza.com,sushiegg-sde-01.disenza.com')

$ErrorActionPreference = "SilentlyContinue"
$vm2s = ($vms -split ',')

foreach($vm in $vm2s){
    if(Test-Path ("\\"+$vm+"\c$\")){
        $s1 = New-PSSession -ComputerName $vm #-Credential $cred # -UseSSL
        write-host "0" $vm

        $command = { 

            write-host "installing sqlxml on $env:COMPUTERNAME" -f green
            cmd /c  "msiexec.exe /i \\disenza.com\dfs\Operations\Software\SQLXML\sqlxml4_x64.msi" /qn    
               
        }
            
    $resp = invoke-command -Session $s1 -scriptblock $command     
    
    # Remove # On next line if you want to delete a Session
    Get-PSSession | Remove-PSSession
    
    }#End test path
}#End foreach VM


