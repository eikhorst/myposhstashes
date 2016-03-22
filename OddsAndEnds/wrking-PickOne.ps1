#### all counters gathered together by server
$ErrorActionPreference = "SilentlyContinue"
#$allvservers = @("ctyws-a02.ETDsoya.com", "ctyws-a03.ETDsoya.com", "ctyws-a04.ETDsoya.com", "ctyws-a05.ETDsoya.com", "ctyws-a07.ETDsoya.com", "ctyws-a08.ETDsoya.com", "ctyws-a09.ETDsoya.com", "ctyws-a10.ETDsoya.com", "ctyws-a11.ETDsoya.com", "ctyws-a12.ETDsoya.com", "ctyws-a13.ETDsoya.com", "ctyws-a14.ETDsoya.com", "ctyws-a15.ETDsoya.com", "ctyws-a16.ETDsoya.com", "ctyws-a17.ETDsoya.com", "ctyws-a18.ETDsoya.com", "ctyws-a19.ETDsoya.com", "ctyws-a20.ETDsoya.com", "ctyws-a21.ETDsoya.com", "ctyws-a22.ETDsoya.com", "ctyws-a23.ETDsoya.com", "ctyws-a24.ETDsoya.com", "ctyws-a25.ETDsoya.com", "ctyws-a26.ETDsoya.com", "ctyws-a27.ETDsoya.com", "ctyws-a28.ETDsoya.com", "ctyws-a29.ETDsoya.com", "ctyws-a30.ETDsoya.com", "ctyws-a31.ETDsoya.com", "ctyws-a32.ETDsoya.com", "ctyws-a33.ETDsoya.com", "ctyws-a34.ETDsoya.com", "ctyws-a35.ETDsoya.com", "ctyws-a36.ETDsoya.com", "ctyws-a37.ETDsoya.com", "ctyws-a38.ETDsoya.com", "ctyws-a39.ETDsoya.com", "ctyws-a40.ETDsoya.com", "ctyws-a41.ETDsoya.com", "ctyws-a42.ETDsoya.com", "ctyws-a43.ETDsoya.com", "ctyws-a44.ETDsoya.com", "ctyws-a45.ETDsoya.com", "ctyws-a46.ETDsoya.com", "ctyws-a47.ETDsoya.com", "ctyws-a48.ETDsoya.com", "ctyws-a49.ETDsoya.com", "ctyws-a50.ETDsoya.com", "ctyws-a51.ETDsoya.com", "ctyws-a52.ETDsoya.com", "ctyws-a53.ETDsoya.com", "ctyws-a54.ETDsoya.com", "ctyws-a55.ETDsoya.com", "ctyws-a56.ETDsoya.com", "ctyws-a57.ETDsoya.com", "ctyws-a58.ETDsoya.com", "ctyws-a59.ETDsoya.com", "ctyws-a60.ETDsoya.com", "ctyws-a61.ETDsoya.com", "ctyws-a62.ETDsoya.com", "ctyws-a63.ETDsoya.com", "ctyws-a64.ETDsoya.com", "ctyws-a65.ETDsoya.com", "ctyws-a66.ETDsoya.com", "ctyws-a67.ETDsoya.com", "ctyws-a94.ETDsoya.com", "ctyws-a69.ETDsoya.com","ctyws-a73.ETDsoya.com","ctyws-a74.ETDsoya.com")
#$allpservers = @("ctywsp-a01.ETDsoya.com","ctywsp-a02.ETDsoya.com","ctywsp-a03.ETDsoya.com","ctywsp-a04.ETDsoya.com","ctywsp-a05.ETDsoya.com","ctywsp-a06.ETDsoya.com","ctywsp-a07.ETDsoya.com","ctywsp-a08.ETDsoya.com","ctywsp-a09.ETDsoya.com","ctywsp-a10.ETDsoya.com")
#$sqlclusters = @("ctysql-a01r.ETDsoya.com","ctysql-a07r.ETDsoya.com","ctysql-a05r.ETDsoya.com","c111zqnETDhs11")
$justtheseservers =  @("ctyws-a72","ctyws-a71")#,"ctyws-a15.ETDsoya.com","ctywsp-a12.ETDsoya.com","ctyws-a39.ETDsoya.com","ctyws-a74.ETDsoya.com")#,"ctywsp-a07.ETDsoya.com","ctyws-a35.ETDsoya.com","ctyws-a52.ETDsoya.com","ctyws-a03.ETDsoya.com")
$sname = "a71a72"
$Start = get-date('2013-05-01 00:44:00 AM')
$End = get-date('2013-05-01 11:00:00 PM')
$dt = (get-date -format g).ToString().Replace("/","-").Replace(" ","_").Replace(":","_") #get-date -uformat "%Y%m%d"
$outfile = "E:\disenza\scripts\out\$dt $sname.csv"
$server = $justtheseservers
@(foreach($svr in $server){
Write-Output "++++  $svr  Counters ++++"
$perfmon = "Process(w3wp*)\Handle Count","Process(w3wp*)\% Processor Time","Process(w3wp*)\ID Process","Redirector\Current Commands","ASP.NET Applications(__Total__)\Request Execution Time","ASP.NET Applications(__Total__)\Requests Executing","ASP.NET v2.0.50727\Requests Queued","ASP.NET Apps v2.0.50727(__Total__)\Requests/Sec","ASP.NET Apps v2.0.50727(__Total__)\Requests Executing","Memory\Available MBytes","Memory\Cache Faults/sec","Memory\Pages/sec","Processor(_total)\% Processor Time","System\Context Switches/sec","System\Processor Queue Length","ASP.NET\Application Restarts","ASP.NET\Requests Rejected","ASP.NET\Worker Process Restarts","Web Service\Current Connections","Web Service\ISAPI Extension Requests/sec"
$perfmon | get-counter -computer $svr -maxsamples 1 
Write-Output "++++  $svr  AppPools ++++"
E:
cd E:\disenza\scripts\getCounters
$r=""; $s="";
$r = .\psexec.exe /acceptEula \\$server c:\windows\system32\inetsrv\appcmd.exe list wp /xml
$xr = [xml]($r)
$xml = $xr.appcmd.WP

$s = .\psexec.exe /acceptEula \\$server cscript.exe iisapp.vbs

if($r -eq ""){try{$msg = $xml | foreach {$_.{WP.NAME}  + " : " + $_.{Apppool.name} + "`r`n"}}catch{write-host $error}}
elseif($s -eq ""){$msg = $s}
	
Write-Output $msg;Write-Host $msg
Write-Output "++++  $svr  Processes ++++"
$procs = get-process w3wp -computername $svr | sort "WorkingSet"
@(foreach($proc in $procs)
{
   $NonPagedMem = [int]($proc.NPM/1024)
   $WorkingSet = [int64]($proc.WorkingSet64/1024)
   $VirtualMem = [int]($proc.VM/1MB)
   $handle = [int]($proc.handles)
   $ptime = [int]($proc.userprocessortime)
   $id= $proc.Id
   $machine = $proc.MachineName
   $process = $proc.ProcessName
   $procdata = new-object psobject
   $procdata | add-member noteproperty NonPagedMem $NonPagedMem
   $procdata | add-member noteproperty WorkingSet $WorkingSet 
   $procdata | add-member noteproperty machine $machine
   $procdata | add-member noteproperty process $process
   $procdata | add-member noteproperty handle $handle
   $procdata | add-member noteproperty PID $id

$procdata | Select-Object machine,process,WorkingSet,NonPagedMem,handle,PID
})

$AppEvent = get-eventlog -logname application -ComputerName $svr -newest 300 #-after $start -before $end #-source w3svc
$AppError = $AppEvent | where  {$_.message -match "reed"}
$AppError | sort TimeWritten

Write-Output "++++  $svr System Event log ++++"
$SysEvent = get-eventlog -logname system -ComputerName $svr -newest 300 #-source w3svc
$SysError = $SysEvent | where  {$_.message -match "reed"}
$SysError | sort TimeWritten
<#
Write-Output "++++  $svr System Event log with lock ++++"
$SysEvent = get-eventlog -logname system -ComputerName $svr -newest 30 #-source w3svc
$SysError = $SysEvent | where  {$_.message -match "lock"}#{$_.message -match "sutherland*"}
$SysError | sort TimeWritten
Write-Output "++++  $svr Security Event log with 4625 ++++"
$SysEvent = get-eventlog -logname Security -ComputerName $svr -newest 15 #-source w3svc
$SysError = $SysEvent | where  {$_.message -match "4625"}#{$_.message -match "sutherland*"}
$SysError | sort TimeWritten#>

}) | Out-file $outfile 
