﻿$vms = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushi.{3}-(.{3}-02|((fil|sql)-(01|02|wi)))'} | select -Expand Name | sort
   
$vm = @('')#,sushiegg-sbc-01.disenza.com,sushiegg-scd-01.disenza.com,sushiegg-sde-01.disenza.com')

$ErrorActionPreference = "SilentlyContinue"

$dtcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
$cred = $dtcred
$vm2s = ($vms -split ',')

foreach($vm in $vms){
    if(Test-Path ("\\"+$vm+"\c$\")){
        $s1 = New-PSSession -ComputerName $vm #-Credential $cred # -UseSSL
        write-host "0" $vm

        $command = { 

            write-host "Forcing windows updates reporting on $env:COMPUTERNAME" -f green
            cmd /c  "wuauclt /reportnow"    
               
        }
            
    $resp = invoke-command -Session $s1 -scriptblock $command     
    
    # Remove # On next line if you want to delete a Session
    Get-PSSession | Remove-PSSession
    
    }#End test path
}#End foreach VM


