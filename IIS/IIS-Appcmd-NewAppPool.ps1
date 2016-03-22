
############  SETUP TidyHTML ###############
c:\windows\system32\inetserv\appcmd.exe add apppool /name:"TidyHTML" /enable32BitAppOnWin64:true
## Make sure the appPool is using Classic Mode too, running as the iusr
c:\windows\system32\inetserv\appcmd.exe add site /site.name:"TidyHTML" /bindings:http://ctyut-a02.ETDsoya.com:8078 /physicalPath:c:\oni\TidyHTML 
## removed the ISAPI filter for F5isapiload balancer, and assigned the appPool made in first command to this site.
