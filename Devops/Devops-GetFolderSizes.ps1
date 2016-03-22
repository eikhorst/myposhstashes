function EmailMe ($subject , $body , $attachment ) 
    {   
    [string[]]$to = ("DSE-vintage <DSE-vintage@disenza.com>")
    $smtp = "localhost"; $from = "$env:computername@disenza.com"
    #$attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
	Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
    }

#$body = @()
#$body += `
$body = $null

$dropped = Get-Content "C:\DSE\scripts\msmq\servers.txt"
@(foreach($drop in $dropped)
    {
    $colItems = 0
    $chk = "\\"+$drop+"\C$\Windows\System32\msmq\storage"
    #$chk
    $colItems = (Get-ChildItem $chk | Measure-Object -property length -sum)
    if($colItems.sum -gt 3221225472)
        {
        "$chk -- " + "{0} (MB)" -f [math]::truncate($colItems.sum / 1MB) >> "C:\DSE\scripts\msmq\logs\MSMQFolderSizes.txt"
        $body = 1
        } 
    $var = ("$chk -- " + "{0} (MB)" -f [math]::truncate($colItems.sum / 1MB))
    }
)

#$body = $body | Out-String
# $body = Get-Content "C:\DSE\scripts\msmq\logs\MSMQFolderSizes.txt"

if($body -ne $null)
    {
    EmailMe -subject "SSWarn: MSMQ Folders Larger than 3 GB" -body "
    $var"
    }