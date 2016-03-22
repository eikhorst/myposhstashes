function EmailMe ($subject , $body , $attachment ) {   
[string[]]$to = "DSE-Deployment <DSE-deployment@disenzaswamy.com>"
    $smtp = "relay-disenza.disenza.com"; $from = "soya.BigAppresetter@disenzaswamy.com"
    #$attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
	Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
}

function ApplyBigAppresetterTo($server){
	#got issues with: server	
	iisreset $server /stop
	$msg = "Stopped IIS"
	Write-Output $msg; Write-Host $msg -foregroundcolor red
	$stats = iisreset $server /status
	$msg = $stats
	Write-Output $msg; Write-Host $msg -foregroundcolor cyan
	

	#loop through all asp.net folders 
	$tmpASProot = "\\$svr\C$\Windows\Microsoft.NET\Framework*"
    $tempdirs = Get-ChildItem -path $tmpASProot -recurse -include Temporary*asp.net

	foreach($tempdir in $tempdirs)
    {
        #list out directory
        write-host $tempdir
        $tempdir = join-path -path $temdir -childpath root
        remove-item -path $tempdir -Recurse -Force        
    }

	iisreset $server /start
	Write-host "----"
	iisreset $server /status
}
	
	$input1 = Read-Host "Enter Server to apply IISReset with TempAsp.net removal:"
	$output = ""
	$outlog = "E:\disenza\scripts\BHOut_$input2.txt"
	$utility = gc env:computername
	$invoker = ([Environment]::UserDomainName + "\" + [Environment]::UserName)	
	$msg = $Startruntime = Get-Date
	Write-Output $msg;Write-Host $msg
	
	$v = [Environment]::UserName; $v = $v.Replace("u","").Replace("m",""); $rname = $null
	$peeps = @{"east"="1234";"west"="0987"}
	foreach($peep in ($peeps.GetEnumerator() | Where-Object {$_.Value -eq $v} ) )
	{$rname = $peep.name}
	if($rname -ne $null){$invoker += " =  $rname"}	
	
if(Test-Connection -Cn $input1 -BufferSize 16 -Count 1 -ea 0 -quiet){  
	$output  = ApplyBigAppresetterTo -server $input1
	$output > $outlog
}
else
{
	$msg =  "Server is unreachable, it did not respond to ping $nl $nl"
	Write-Output $msg; Write-Host $msg -foregroundcolor red
}

#$out2 = gc $output
$msg = $Endruntime = Get-Date
Write-Output $msg;Write-Host $msg
EmailMe -subject "SSManual: BigAppresetter : $input1" -body "
+++Time Start:      $Startruntime +++
$output

+++Time EnE:      $Endruntime +++
##################################
This job was run on 
Server:`t$utility 
Invoker:`t$invoker 
Location:            E:\disenza\scripts\Appresetters\BigAppresetter.ps1
" # -attachment $output

