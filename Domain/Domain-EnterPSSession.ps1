
#$servers = Read-host -prompt "VM e.g(sushiice-sia-01)" #@('sushiice-sia-02')
#$servers = @('sushigum-sfe-01','sushifig-sfe-02')
$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushi'} | select -Expand Name | sort

$body = @()

$body += `
foreach($server in $servers){

    $s = New-PSSession -ComputerName $server 
    write-output "====== $server ======"
    $command = { 
    
    #region Check InetPub/Mailroot
    if(test-path 'C:\inetpub\mailroot\Queue'){
        $stuckemails = (GCI 'C:\inetpub\mailroot\Queue').count
        if($stuckemails -gt 0){
            write-output "$stuckemails Emails in \\$env:ComputerName\c$\inetpub\mailroot\queue"
        }
    }
    #endregion


    #region  Ping BP zds server  ---------------------------------------->>
    
    if((test-connection 30.51.2.5 -quiet) -eq $true){
        #"Ping Success to baconPASM-01 from: $env:ComputerName" 
    }
    else
    {
        "Ping Failed to baconPASM-01 from: $env:ComputerName" 
    }
    
    #endregion Ping

    
    #region  Checking server health

        #wuauclt.exe /reportnow
        if($env:COMPUTERNAME -match '(A|B)P-(.){3}-(FIL|SQL)'){
            write-output "***** $env:COMPUTERNAME Free drive space *****" 
            get-psdrive | ?{$_.Provider -match "FileSystem"} | %{ $_.Name, (($_.Free)/1GB) } | FT Drive, Free
        }
        elseif($env:COMPUTERNAME -match '(A|B)P-(.){3}-(s|d)'){
            #write-host "importing a module"
            #Write-Output "About to run tricky PowerShell"
            
            Import-Module WebAdministration -ErrorAction SilentlyContinue; 
            $sites = Get-ChildItem IIS:\Sites
            $sites = Get-ChildItem IIS:\Sites            
            if($sites.Count -gt 0){          
            write-output "Websites on $env:Computername"  
                <#foreach($site in $sites){
                    $site.Name
                }#>
                C:\windows\system32\inetsrv\appcmd.exe list wp
                get-process -Name w3wp | %{$_.id,$_.cpu,$_.workingset} | sort WorkingSet -Descending | FT ID,CPU,WorkingSet                
            }
        }
        else{}

    #endregion Checking server health
    }
    Invoke-Command -Session $s -ScriptBlock $command     
}


$body = $body | Out-String


$MailMessage  = @{
From = "sushiju-firep@disenza.com"
To = "firep@disenza.com"
Subject = "Stuck Emails, Ping baconzds-03, and disk space and appPool sizes"
SMTPServer = "smtp.disenza.com"
Body = $body
}

Send-MailMessage @MailMessage


Get-PSSession | Remove-PSSession




