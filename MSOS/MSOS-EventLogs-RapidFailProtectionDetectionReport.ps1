#### all counters gathered together by server
$ErrorActionPreference = "SilentlyContinue"
$allvservers = @("ctyws-a02.h1soya.com", "ctyws-a03.h1soya.com", "ctyws-a04.h1soya.com", "ctyws-a05.h1soya.com", "ctyws-a07.h1soya.com", "ctyws-a08.h1soya.com", "ctyws-a09.h1soya.com", "ctyws-a10.h1soya.com", "ctyws-a11.h1soya.com", "ctyws-a12.h1soya.com", "ctyws-a13.h1soya.com", "ctyws-a14.h1soya.com", "ctyws-a15.h1soya.com", "ctyws-a16.h1soya.com", "ctyws-a17.h1soya.com", "ctyws-a18.h1soya.com", "ctyws-a19.h1soya.com", "ctyws-a20.h1soya.com", "ctyws-a21.h1soya.com", "ctyws-a22.h1soya.com", "ctyws-a23.h1soya.com", "ctyws-a24.h1soya.com", "ctyws-a25.h1soya.com", "ctyws-a26.h1soya.com", "ctyws-a27.h1soya.com", "ctyws-a28.h1soya.com", "ctyws-a29.h1soya.com", "ctyws-a30.h1soya.com", "ctyws-a31.h1soya.com", "ctyws-a32.h1soya.com", "ctyws-a33.h1soya.com", "ctyws-a34.h1soya.com", "ctyws-a35.h1soya.com", "ctyws-a36.h1soya.com", "ctyws-a37.h1soya.com", "ctyws-a38.h1soya.com", "ctyws-a39.h1soya.com", "ctyws-a40.h1soya.com", "ctyws-a41.h1soya.com", "ctyws-a42.h1soya.com", "ctyws-a43.h1soya.com", "ctyws-a44.h1soya.com", "ctyws-a45.h1soya.com", "ctyws-a46.h1soya.com", "ctyws-a47.h1soya.com", "ctyws-a48.h1soya.com", "ctyws-a49.h1soya.com", "ctyws-a50.h1soya.com", "ctyws-a51.h1soya.com", "ctyws-a52.h1soya.com", "ctyws-a53.h1soya.com", "ctyws-a54.h1soya.com", "ctyws-a55.h1soya.com", "ctyws-a56.h1soya.com", "ctyws-a57.h1soya.com", "ctyws-a58.h1soya.com", "ctyws-a59.h1soya.com", "ctyws-a60.h1soya.com", "ctyws-a61.h1soya.com", "ctyws-a62.h1soya.com", "ctyws-a63.h1soya.com", "ctyws-a64.h1soya.com", "ctyws-a65.h1soya.com", "ctyws-a66.h1soya.com", "ctyws-a67.h1soya.com", "ctyws-a94.h1soya.com", "ctyws-a69.h1soya.com","ctyws-a73.h1soya.com","ctyws-a74.h1soya.com","ctyws-a75.h1soya.com","ctyws-a76.h1soya.com","ctyws-a77.h1soya.com","ctyws-a78.h1soya.com","ctyws-a79.h1soya.com","ctyws-a80.h1soya.com","ctyws-a81.h1soya.com","ctyws-a82.h1soya.com","ctyws-a83.h1soya.com","ctyws-a154.h1soya.com","ctyws-a85.h1soya.com","ctyws-a86.h1soya.com","ctyws-a87.h1soya.com","ctyws-a88.h1soya.com","ctyws-a89.h1soya.com")
$allpservers = @("ctywsp-a01.h1soya.com","ctywsp-a02.h1soya.com","ctywsp-a03.h1soya.com","ctywsp-a04.h1soya.com","ctywsp-a05.h1soya.com","ctywsp-a06.h1soya.com","ctywsp-a07.h1soya.com","ctywsp-a08.h1soya.com","ctywsp-a09.h1soya.com","ctywsp-a10.h1soya.com")
$sqlclusters = @("ctyws-a01r.h1soya.com","ctysql-a07r.h1soya.com","ctysql-a05r.h1soya.com","c111zqnh1hs11","ctysql-a14r.h1soya.com")
$utilservers = @("ctyut-a01","ctyut-a02","ctyut-a03","ctyut-a04","ctyut-a05","ctyut-a06","ctyut-a07","ctyut-a08","ctyut-a09","ctyut-a10","ctyut-a11","ctyut-a12","ctyut-a13","ctyut-a14","ctyut-a15")
$justtheseservers =  $allpservers + $allvservers + $utilservers + $sqlclusters
$sname = "allservers"
#$Start = get-date('2013-08-01 03:30:00 AM')
#$End = get-date('2013-08-01 23:59:59')
$dt = (get-date -format g).ToString().Replace("/","-").Replace(" ","_").Replace(":","_") #get-date -uformat "%Y%m%d"
$outfile = "\\ctyut-a04\d$\disenza\www\ErrorLogging\LoggingUI\support\logs\eventvwr\$dt $sname.csv"
$server = $justtheseservers
$FullArray = @()
$daysback = [datetime]::Now.AddDays(-1)
$time = Measure-command{
foreach($svr in $server){   
#Region SQL Freeze
$SQLEvents = ""
$daysback = (Get-Date).Adddays(-17)
$endtime = (Get-Date).Adddays(-16)
$SQLEvents = Get-WinEvent -MaxEvents 10 -ComputerName $svr -FilterHashtable @{logname='application';id='1309'; level=3; starttime=$daysback; endtime=$endtime;}
$SQLEvents | sort TimeWritten -descending
$Logname = "SQLFreeze"          
            if($SQLEvents -ne $null){
            foreach($SQLEvent in $SQLEvents){
            if($SQLEvent.message -match 'stansport-level'){
               $tmpObj3 = New-Object Object
               $tmpObj3 | add-member -membertype noteproperty -name "Server" -value $svr
               $tmpObj3 | add-member -membertype noteproperty -name "MachineName" -value $SQLEvent.MachineName
               $tmpObj3 | add-member -membertype noteproperty -name "LogName" -value $Logname
               $tmpObj3 | add-member -membertype noteproperty -name "TimeCreated" -value $SQLEvent.TimeCreated
               $tmpObj3 | add-member -membertype noteproperty -name "ID" -value $SQLEvent.ID
               $tmpObj3 | add-member -membertype noteproperty -name "Provider" -value $SQLEvent.ProviderName
               $tmpObj3 | add-member -membertype noteproperty -name "Message" -value $SQLEvent.Message
               $FullArray += $tmpObj3
               }
            }}    
#endregion SQL Freeze
#Write-Output "++++ $svr App Event Error 1000 ++++"
$AppEvents = ""
$daysback = [datetime]::Now.AddDays(-1)
$AppEvents = Get-WinEvent -MaxEvents 10 -ComputerName $svr -FilterHashtable @{logname='application';id='1000';level=2;starttime=$daysback}
$AppEvents | sort TimeWritten -descending
$Logname = "Application"            
            if($AppEvents -ne ""){
            foreach($AppEvent in $AppEvents){
               $tmpObj = New-Object Object
               $tmpObj | add-member -membertype noteproperty -name "Server" -value $svr
               $tmpObj | add-member -membertype noteproperty -name "MachineName" -value $AppEvent.MachineName
               $tmpObj | add-member -membertype noteproperty -name "LogName" -value $Logname
               $tmpObj | add-member -membertype noteproperty -name "TimeCreated" -value $AppEvent.TimeCreated
               $tmpObj | add-member -membertype noteproperty -name "ID" -value $AppEvent.ID
               $tmpObj | add-member -membertype noteproperty -name "Provider" -value $AppEvent.ProviderName
               $tmpObj | add-member -membertype noteproperty -name "Message" -value $AppEvent.Message
               $FullArray += $tmpObj
            }}            

#Write-Output "++++ $svr System Event log 5002 ++++"
$SysEvents = ""
$daysback = [datetime]::Now.AddDays(-1)
$SysEvents = Get-WinEvent -MaxEvents 10 -ComputerName $svr -FilterHashtable @{logname='system';id='5002';timecreated=$daysback}
$SysEvents | sort TimeWritten -descending
$Logname = "System"         
            if($SysEvents -ne ""){
            foreach($SysEvent in $SysEvents){
                $tmpObj2 = New-Object Object
                $tmpObj2 | add-member -membertype noteproperty -name "Server" -value $svr
                $tmpObj2 | add-member -membertype noteproperty -name "MachineName" -value $SysEvent.MachineName            
                $tmpObj2 | add-member -membertype noteproperty -name "LogName" -value $Logname
                $tmpObj2 | add-member -membertype noteproperty -name "TimeCreated" -value $SysEvent.TimeCreated
                $tmpObj2 | add-member -membertype noteproperty -name "ID" -value $SysEvent.ID
                $tmpObj2 | add-member -membertype noteproperty -name "Provider" -value $SysEvent.ProviderName
                $tmpObj2 | add-member -membertype noteproperty -name "Message" -value $SysEvent.Message
                $FullArray += $tmpObj2
            }}
} 
}
$FullArray| Sort TimeCreated -descending | Export-CSV $outfile -notypeinformation
$time