while ($true){

measure-command{

$date = get-date -Format yyMMdd ; Write-host $date

$dateP1 = ((Get-Date).AddDays(1)).ToString("yyMMdd"); Write-host $dateP1

$sitelog = "E:\disenza\logfiles\W3SVC10000158"
$sizelog = $sitelog + "_spl_"+$date+".txt"
$interval = 5

cd $sitelog
$bmfile = gci | ?{-not $_.PsIsContainer} | sort CreationTime | select -last 1
$currentIISlogDate = ($bmfile.Name.split(".")[0]).Split('x')[1]
Write-host "Date: " $date 
write-host $sizelog
Write-host "CurrentIISLogDate: " $currentIISlogDate
## 
# Does the sizelog file match the most recent IIS log file's date?  if not then create a new sizelog
if($date -ne $currentIISlogDate){
    $sizelog = $sitelog + "_spl_"+$dateP1+".txt"
}

Write-host $sizelog

 $gclines = ( gc $bmfile | measure-object -line).Lines
$lastlines = 0
if(test-path $sizelog){ $lastlines =  ((gc $sizelog | select -last 1).Split(' '))[4] }

$deltalines = $gclines - $lastlines
 $gcilength = (gci $bmfile).Length
 
 $timestamp = get-date -format hh:mm
 
 $bmfile.Name.ToString() +" "+ $deltalines +" "+ $timestamp.ToString()+" "+ $gcilength + " " + $gclines | out-file $sizelog -Append
 
 #email warnings if deltalines is @ this #
 $smtp = "relay-disenza.disenza.com"
 $body = "File LinesAdded Timestamp FileLength TotalLines`t`r`n" + $bmfile.Name.ToString() +" "+ $deltalines +" "+ $timestamp.ToString()+" "+ $gcilength + " " + $gclines
 $to = @("firep@disenza.com","msnbc@disenza.com"); $from = $env:ComputerName+"_soyaLogSizeMonitor@disenzaone.com"
# $subject = "This is just a test"
# Send-MailMessage –From $from –To $to –Subject "$subject" –Body "$body" –SmtpServer $smtp 
 
 if($deltalines -gt "5000"){ 
 $subject = "SSWarn (soya-" +  $env:ComputerName + ") Baker McKenzie Log file logged over 5000 lines in the last 5 minutes"
 Send-MailMessage –From $from –To $to –Subject "$subject" –Body "$body" –SmtpServer $smtp }
 
 if($deltalines -gt "10000"){ 
 $subject = "SSPage (soya-" +  $env:ComputerName + ") Baker McKenzie Log file logged over 10000 lines in the last 5 minutes"
 Send-MailMessage –From $from –To $to –Subject "$subject" –Body "$body" –SmtpServer $smtp }
 

}
    [GC]::Collect()
    sleep -seconds (60 * $interval) 
}