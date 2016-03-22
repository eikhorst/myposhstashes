function EmailMe ($subject , $body , $attachment ) {
[string[]]$to = "firep@disenza.com" #"DSE-Deployment <DSE-deployment@disenzaswamy.com>"
    $smtp = "smtp.disenza.com"; $from = "BAM.pasm@TSHprod.com"
    if($attachment -ne $null){
        $attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp
    }
    else{ Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   }
}

$SMTPSvcStatus = (get-service -ComputerName sushipasm-01.disenza.com -name smtpsvc).Status
$IsRunning = $true

if( $SMTPSvcStatus -ne "Running")
{
    $IsRunning = $false
    write-host "SMTPSVC is:" $SMTPSvcStatus -f red
#    (new-Object System.ServiceProcess.ServiceController('SMTPSVC','sushipasm-01.disenza.com')).Start()
    get-service -ComputerName sushipasm-01.disenza.com -name smtpsvc | Restart-Service
}
else{
    $IsRunning = $true
    write-host "SMTPSVC is:" $SMTPSvcStatus -f green
}

if(!($IsRunning)){
    EmailMe -subject "SMTP is down on Pasm" -body "Please re-start the smtpsvc"
}
