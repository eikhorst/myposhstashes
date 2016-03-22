f$allmailboxes = get-mailbox #-identity firep@disenza.com
foreach($mailbox in $allmailboxes){
	$temp = get-mailboxjunkemailconfiguration $mailbox.alias
	
	$temp.TrustedSendersAndDomains += "stratexpartners.com"
	Set-MailboxJunkEmailConfiguration -Identity $mailbox.alias -TrustedSendersAndDomains $Temp.TrustedSendersAndDomains					
	write-host "$mailbox - updated"

}