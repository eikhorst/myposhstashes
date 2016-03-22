#### all counters gathered together by server
$ErrorActionPreference = "SilentlyContinue"
$allvservers = @("ctyws-a02.ETDsoya.com", "ctyws-a03.ETDsoya.com", "ctyws-a04.ETDsoya.com", "ctyws-a05.ETDsoya.com", "ctyws-a07.ETDsoya.com", "ctyws-a08.ETDsoya.com", "ctyws-a09.ETDsoya.com", "ctyws-a10.ETDsoya.com", "ctyws-a11.ETDsoya.com", "ctyws-a12.ETDsoya.com", "ctyws-a13.ETDsoya.com", "ctyws-a14.ETDsoya.com", "ctyws-a15.ETDsoya.com", "ctyws-a16.ETDsoya.com", "ctyws-a17.ETDsoya.com", "ctyws-a18.ETDsoya.com", "ctyws-a19.ETDsoya.com", "ctyws-a20.ETDsoya.com", "ctyws-a21.ETDsoya.com", "ctyws-a22.ETDsoya.com", "ctyws-a23.ETDsoya.com", "ctyws-a24.ETDsoya.com", "ctyws-a25.ETDsoya.com", "ctyws-a26.ETDsoya.com", "ctyws-a27.ETDsoya.com", "ctyws-a28.ETDsoya.com", "ctyws-a29.ETDsoya.com", "ctyws-a30.ETDsoya.com", "ctyws-a31.ETDsoya.com", "ctyws-a32.ETDsoya.com", "ctyws-a33.ETDsoya.com", "ctyws-a34.ETDsoya.com", "ctyws-a35.ETDsoya.com", "ctyws-a36.ETDsoya.com", "ctyws-a37.ETDsoya.com", "ctyws-a38.ETDsoya.com", "ctyws-a39.ETDsoya.com", "ctyws-a40.ETDsoya.com", "ctyws-a41.ETDsoya.com", "ctyws-a42.ETDsoya.com", "ctyws-a43.ETDsoya.com", "ctyws-a44.ETDsoya.com", "ctyws-a45.ETDsoya.com", "ctyws-a46.ETDsoya.com", "ctyws-a47.ETDsoya.com", "ctyws-a48.ETDsoya.com", "ctyws-a49.ETDsoya.com", "ctyws-a50.ETDsoya.com", "ctyws-a51.ETDsoya.com", "ctyws-a52.ETDsoya.com", "ctyws-a53.ETDsoya.com", "ctyws-a54.ETDsoya.com", "ctyws-a55.ETDsoya.com", "ctyws-a56.ETDsoya.com", "ctyws-a57.ETDsoya.com", "ctyws-a58.ETDsoya.com", "ctyws-a59.ETDsoya.com", "ctyws-a60.ETDsoya.com", "ctyws-a61.ETDsoya.com", "ctyws-a62.ETDsoya.com", "ctyws-a63.ETDsoya.com", "ctyws-a64.ETDsoya.com", "ctyws-a65.ETDsoya.com", "ctyws-a66.ETDsoya.com", "ctyws-a67.ETDsoya.com", "ctyws-a94.ETDsoya.com", "ctyws-a69.ETDsoya.com","ctyws-a73.ETDsoya.com","ctyws-a74.ETDsoya.com","ctyws-a75.ETDsoya.com","ctyws-a76.ETDsoya.com","ctyws-a77.ETDsoya.com","ctyws-a78.ETDsoya.com","ctyws-a79.ETDsoya.com","ctyws-a80.ETDsoya.com","ctyws-a81.ETDsoya.com","ctyws-a82.ETDsoya.com","ctyws-a83.ETDsoya.com","ctyws-a154.ETDsoya.com","ctyws-a85.ETDsoya.com","ctyws-a86.ETDsoya.com","ctyws-a87.ETDsoya.com","ctyws-a88.ETDsoya.com","ctyws-a89.ETDsoya.com")
$allpservers = @("ctywsp-a01.ETDsoya.com","ctywsp-a02.ETDsoya.com","ctywsp-a03.ETDsoya.com","ctywsp-a04.ETDsoya.com","ctywsp-a05.ETDsoya.com","ctywsp-a06.ETDsoya.com","ctywsp-a07.ETDsoya.com","ctywsp-a08.ETDsoya.com","ctywsp-a09.ETDsoya.com","ctywsp-a10.ETDsoya.com")
$sqlclusters = @("ctyws-a01r.ETDsoya.com","ctysql-a07r.ETDsoya.com","ctysql-a05r.ETDsoya.com","c111zqnETDhs11","ctysql-a14r.ETDsoya.com")
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