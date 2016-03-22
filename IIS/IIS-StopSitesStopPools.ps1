
#stops all sites:
cd c:\windows\system32\inetsrv\

appcmd.exe list site /xml /state:"$=started" | appcmd stop site /in


#stop all app pools:

appcmd.exe list apppool /xml | appcmd stop apppool /in