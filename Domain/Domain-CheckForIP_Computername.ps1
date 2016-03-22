$start= '10.10.20.'
$end = '10.10.20.255'

1..254 | %{ "$start$_", ([System.Net.Dns]::GetHostbyAddress("$start$_")).HostName | Out-File c:\temp\puters.txt -NoClobber -Append}

#$IPAddress = 10.10.20.8
#([System.Net.Dns]::GetHostbyAddress($IPAddress)).HostName