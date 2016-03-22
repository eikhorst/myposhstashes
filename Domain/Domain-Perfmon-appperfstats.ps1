#region Server selection

#$servers = Read-host -prompt "VM e.g(sushiice-sia-01)" #@('sushiice-sia-02')
#$servers = @('sushigum-sfe-01','sushifig-sfe-02')

$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushi'} | select -Expand Name | sort

#endregion

#region Body object creation - for publishing to text in the email
$body = @()

$body += `
foreach($server in $servers){

    $s = New-PSSession -ComputerName $server 

    $command = { 
    #$env:COMPUTERNAME # -f darkcyan -b DarkGreen

    #region  Ping BP zds server  ---------------------------------------->>
    <#
    if((test-connection 30.51.2.5 -quiet) -eq $true){
        "Successful: $env:ComputerName" 
    }
    else
    {
        "FaileE: $env:ComputerName" 
    }
    #>
    #endregion Ping

    #region WSUS windows updates ---------------------------------------->>

        #wuauclt.exe /reportnow

    #endregion WSUS windows updates

    #region   Checking server health  ---------------------------------------->>
<#
        if($env:COMPUTERNAME -match '(A|B)P-(.){3}-(FIL|SQL)'){
            write-host "***** $env:COMPUTERNAME Free drive space *****" -f DarkCyan 
            get-psdrive | ?{$_.Provider -match "FileSystem"} | %{$_.Name, ($_.Free/1GB)} | FL Drive, Free
        }
        else{
            #write-host "importing a module"
            #Write-Output "About to run tricky PowerShell"
            $pids = C:\windows\system32\inetsrv\appcmd.exe list wp

            Import-Module WebAdministration -ErrorAction SilentlyContinue; 
            $sites = Get-ChildItem IIS:\Sites
            $sites = Get-ChildItem IIS:\Sites            
            
            foreach($site in $sites){
                $site.Name + ", "+ (($pids | select-string "$($site.Name)") -split "`"")[1] 
                #(($site.bindings.Collection | ?{$_.bindingInformation -match ':80:'} | %{$_.bindingInformation}).Trim('80:'))
                
            }
            get-process -Name w3wp | FT -Property ID,CPU,WorkingSet

            
        }
#> 

    #endregion Checking server



    }
    Invoke-Command -Session $s -ScriptBlock $command     
}


$body = $body | Out-String

#endregion

#region MailSetup and Send
$MailMessage  = @{
From = "sushiju-firep@disenza.com"
To = "firep@disenza.com"
Subject = "Test-Connection status for all servers going to baconzds-02"
SMTPServer = "smtp.disenza.com"
Body = $body
}

Send-MailMessage @MailMessage

#endregion

#region Cleanup Sessions
Get-PSSession | Remove-PSSession

#endregion