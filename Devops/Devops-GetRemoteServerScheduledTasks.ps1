$vm2s = @("sushisched-app-01","sushisched-env-01")
$username = "disenza\da-firep"
$password = cat c:\temp\dtss.txt | ConvertTo-SecureString

$ErrorActionPreference = "Continue"

$dtcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
$cred = $dtcred
$vm2s = ($vm2s -split ',')

foreach($vm in $vm2s){
    #if(Test-Connection -ComputerName $vm){
    $s1 = New-PSSession -ComputerName $vm -Credential $cred # -UseSSL
    write-host $vm
    $command ={
        $outfile = 'c:\admin\Jobs.txt'
        write-host $outfile
        #$outfile = "c:\temp\"+ $vm +".txt"
        #write-host $outfile

        Get-ScheduledTask -TaskPath "\DSE\" | Export-ScheduledTask | Out-File -FilePath $outfile
    }
    
    $resp = invoke-command -Session $s1 -scriptblock $command  

    # Remove # On next line if you want to delete a Session
    Get-PSSession $s1 | Remove-PSSession
    #}
}
