Search-Mailbox -Identity "vintage-oncall" -SearchQuery "receive: 08/30/2012..5/30/2013" -DeleteContent -Confirm

Search-Mailbox -Identity "msnbc@disenza.com" -SearchQuery "receive: 08/30/2012..5/30/2013" -TargetMailbox "vintage-oncall@disenza.com" -TargetFolder "DT-TestDelete" -logonly -loglevel Full

search-mailbox -identity "msnbc@disenza.com" -searchquery "Subject:Mail Delivery Subsystem*" -DeleteContent

search-mailbox -identity msnbc@disenza.com -searchquery "Subject:New Prod HBA*" -DeleteContent	-Confirm:$false -Force

## for bulk deletes of 10k emails at a time:
1..30 | ForEach-Object { $_;search-mailbox -identity msnbc@disenza.com -searchquery "Subject:New Prod HBA*" -DeleteContent	-Confirm:$false -Force; Start-Sleep -s 300;}

get-mailbox -ResultSize unlimited | Search-Mailbox -SearchQuery subject:"Thing I want deleted" -TargetFolder "Calendar" -DeleteContent -TargetMailbox:"reference mailbox"