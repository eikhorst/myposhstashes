
#$servers = Read-host -prompt "VM e.g(sushiice-sia-01)" #@('sushiice-sia-02')
#$servers = @('sushigum-sfe-01','sushifig-sfe-02')
$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushi'} | select -Expand Name | sort


$body = @()

$body += `
foreach($server in $servers){

    $s = New-PSSession -ComputerName $server 

    $command = { 
    #$env:COMPUTERNAME # -f darkcyan -b DarkGreen

    #region  Ping BP zds server  ---------------------------------------->>

    if((test-connection 30.51.2.5 -quiet) -eq $true){
        "Successful: $env:ComputerName" 
    }
    else
    {
        "FaileE: $env:ComputerName" 
    }

    #endregion Ping

    }
    Invoke-Command -Session $s -ScriptBlock $command     
}


$body = $body | Out-String


$MailMessage  = @{
From = "sushiju-firep@disenza.com"
To = "DSE-vintage@disenza.com"
Subject = "Test-Connection From AP servers To baconZDS-02"
SMTPServer = "smtp.disenza.com"
Body = $body
}

Send-MailMessage @MailMessage


Get-PSSession | Remove-PSSession