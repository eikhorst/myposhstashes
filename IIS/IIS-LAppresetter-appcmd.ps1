function EmailMe ($subject , $body , $attachment ) {   
[string[]]$to = @("DSE-vintage@disenza.com")
    $smtp = "smtp.disenza.com"
    $from = "Bam.LittleAppresetter@disenza.com"
    #SmtpClient.servicepoint.maxidletime=1000;
    if($attachment -ne $null){
        $attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp 
    } 
    else {
	    Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" -SmtpServer $smtp 
    }   
}

#$vm = 'sushi1st-sab-01'      
$vm = (Read-Host -Prompt "Webserver").ToUpper()
#$username = "disenza\da-firep"
#$password = cat c:\temp\dtss.txt | ConvertTo-SecureString
#$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
$s1 = New-PSSession -ComputerName $vm # -Credential $cred # -UseSSL
$Appresettertemp = "\\$vm\c$\temp\Appresetter.txt"; write-host $Appresettertemp
if(!(Test-Path $Appresettertemp)){new-item -ItemType File $Appresettertemp | out-null }else{
clear-content $Appresettertemp}


$command1 = {
cd c:\windows\system32\inetsrv\
$msgTitle= "`n====== WorkerProcesses ====== `n"
write-output $msgTitle
$msg = $apps = ( .\appcmd.exe list wp )
(write-output $msg) -replace "WP","`nWP"
 
 }

$command2 = {cd c:\windows\system32\inetsrv\
$msg = "`n====== ApplicationPools ======`n" 

$msg += ( .\appcmd.exe list apppools )
(write-output $msg) -replace "APPPOOL","`nAPPPOOL"
 }

$command3 = {cd c:\windows\system32\inetsrv\
$Appresetterthis = "c:\temp\Appresetter.txt"
$blah = Get-Content $Appresetterthis -totalcount 1

$msg = "`n`n====== Recycling AppPool ======`n" 

$msg += ( .\appcmd.exe recycle apppool /apppool.name:$blah)
write-output $msg.ToUpper()"`n"

 }

$resp1 = invoke-command -Session $s1 -ScriptBlock $command1 
$resp1

#get response from user for the apppool:
$applicationPools = $resp1 | %{ ($_.split(':')[1]) -replace '\)',"" } | sort
$i=0
$applicationPools | % { 
"[{0}]`t{1}" -f $i, $($applicationPools[$i])
 $i++
 }


$response = Read-Host -Prompt "`nSelect Application Pool to recycle"    
$applicationPools[$response].ToUpper() | out-file $Appresettertemp
$appPoolTOBeRecycled = get-content $Appresettertemp -TotalCount 1

$resp2 = invoke-command -Session $s1 -ScriptBlock $command2 
#$resp2
$resp3 = invoke-command -Session $s1 -ScriptBlock $command3   
$resp3

sleep 10

$resp4 = invoke-command -Session $s1 -ScriptBlock $command1 
$resp4

$resp5 = get-process w3wp -computername $vm | sort WorkingSet | select ProcessName, ID, WorkingSet, Handles
$resp5

EmailMe -subject "SSManual: LittleAppresetter : $vm : $appPoolTOBeRecycled " -body "
$resp1
$resp2
$resp3
$resp4
$resp5
##################################
This job was run on `n 
Server: `t $vm
Invoker: `t $env:username 
Location: `t c:\git\repos\azure\pasm-Appresetters\LittleAppresetter-appcmd.ps1
" 

Get-PSSession | Remove-PSSession

pause