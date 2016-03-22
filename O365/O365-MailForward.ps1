#Set-Mailbox -Identity "Nicole Benzer" -ForwardingSMTPAddress "tlord@disenza.com"
##############################
##  References:
##  http://o365info.com/forward-mail-powershell-commands-quick/
##  http://community.office365.com/en-us/w/exchange/2191.how-to-forward-email-in-office-365.aspx
##############################
New-MailContact -Name "Nicole Benzer"  -ExternalEmailAddress nbenzer@tellyourstoryinc.com

Set-MailContact "Nicole Benzer" -emailaddresses SMTP:benzer@tellyourstoryinc.com,tlord@disenza.com

