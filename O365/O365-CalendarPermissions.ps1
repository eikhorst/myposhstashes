#CalendarPermissions

get-mailboxfolderpermission -identity kpeekna@disenza.com:\calendar


add-mailboxfolderpermission kpeekna@disenza.com:\Calendar -user anonymous -accessrights AvailabilityOnly

get-casmailbox -identity firep@disenza.com | fl >c:\temp\test.csv


get-mailboxstatistics -identity firep@disenza.com | fl >c:\temp\test1.csv


### remediation steps from Microsoft

Set-mailbox -identity kpeekna@disenza.com -CalendarRepairDisabled $true
Set-mailbox -identity kpeekna@disenza.com -CalendarRepairDisabled $false
 
