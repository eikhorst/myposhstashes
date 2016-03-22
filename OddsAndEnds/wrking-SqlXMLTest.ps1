function EmailMe ($subject, $body, $attachment ) {   
[string[]]$to = @("firepstan+m1ytbjinlctz89l7yjjp@boards.trello.com")  ## this is the next board in trello.
    $smtp = "localhost"
    $from = "$env:Computername@disenza.com"
    #SmtpClient.servicepoint.maxidletime=1000;
    if($attachment -ne $null){
        $attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp 
    } 
    else {
	    Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" -SmtpServer $smtp 
    }
    
}

$sqlxmlisInstalled = $false
if(Test-Path 'c:\program files (x86)\sqlxml 4.0\'){
    $sqlxmlisInstalled = $true
}

if($sqlxmlisInstalled){
EmailMe -subject "$env:Computername : SQLXML 4.0 is installed" -body "SQLXML 4.0 is installed $env:Computername : Success"
}
else
{
EmailMe -subject "$env:Computername : SQLXML 4.0 NOT installed" -body "SQLXML 4.0 NOT installed on $env:Computername : Failed"
}


<#
########### TELNET TEST for smtp.disenza.com the hmailserver we run on sushisftp-01

open a cmd prompt
 
telnet smtp.disenza.com 25
ehlo me
mail from: test@disenza.com
rcpt to: firep@disenza.com
data
subject: this is the subject
here is my body
.

######
# Remember the last dot, that ends the message.
#>