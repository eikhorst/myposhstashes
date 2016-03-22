#To search in single mailbox
search-mailbox -identity userA -searchquery "KinE:meetings and Subject:Subject of meeting and from:User@Domain.com" -targetmailbox Adminmailbox -TargetFolder "SearchData" -logonly -loglevel full

#To delete items from Single mailbox
search-mailbox -identity userA -searchquery "KinE:meetings and Subject:Subject of meeting and from:User@Domain.com" -targetmailbox Adminmailbox -TargetFolder "SearchData" -loglevel full -DeleteContent

#To search items for all mailboxes
Get-Mailbox -ResultSize Unlimited | search-mailbox -searchquery "KinE:meetings and Subject:Subject of meeting and from:User@Domain.com" -targetmailbox Adminmailbox -TargetFolder "SearchData" -logonly -loglevel full

#To delete items from all mailboxes
Get-Mailbox -ResultSize Unlimited | search-mailbox -searchquery "KinE:meetings and Subject:Subject of meeting and from:User@Domain.com" -targetmailbox Adminmailbox -TargetFolder "SearchData" -loglevel full –DeleteContent