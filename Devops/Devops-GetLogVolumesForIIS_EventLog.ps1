$logNames = @("Application","System")
$servers = gc "\\ctyfs-a01s\dsw\mypow\AllsoyaServers.txt" #@("ctyws-a55","ctyws-a56")
#
$array = @(); $outfile = "\\ctyut-a11\d$\disenza\scripts\out\EventLogVolume.csv"

foreach($server in $servers){
if((Test-Connection -ComputerName $server -BufferSize 16 -Count 1 -ea 0 -quiet)){
$sitelogs = "\d$\disenza\logfiles\"
$sitelogs = "\\$server"+$sitelogs
$ThisDatesLogSize = $null
$ThisServersIISLogSizeForOneDay = ""
Write-Host $logfilepath -foregroundcolor Blue

    foreach($logName in $logNames){
    $log = Get-WmiObject -computername $server -Class Win32_NTEventLogFile  -filter "LogFileName = '$logName'"

    $log.MaxFileSize
    $log.FileSize
    $log.NumberOfRecords
    $numRecords = $log.NumberOfRecords

    $lastlog = $log.NumberOfRecords + 1

    $newindex = (Get-eventlog -computername $server -logname $logName -newest 1).index

    $lastindex = $newindex - $numRecords + 1

    $query = "Select * from Win32_NTLogEvent "

    $query+= "Where Logfile = '$logName' "

    $query+= "and RecordNumber=$lastindex"

    $event = Get-WmiObject -ComputerName $server -Query $query

    $date = [Management.ManagementDateTimeConverter]::ToDateTime($event.TimeGenerated)

    foreach($sitelog in (gci $sitelogs)){
        if(test-path $sitelog.FullName -pathType container){
            $ThisDate = get-date("11/7/2013") -Format "yyMMdd"
            $ThisDate += ".log"            
            $fullpath = Join-Path -p $sitelogs -ChildPath $sitelog
            Write-Host $fullpath
            $ThisDatesLogSize += (gci $fullpath -Filter "*$($ThisDate)").Length
             
        }                
    }
    
    $ThisServersIISLogSizeForOneDay = $ThisDatesLogSize

#########  Push data into the csv:
                        $tmpObj = New-Object Object 
    		            $tmpObj | add-member -membertype noteproperty -name "Server" -value $server 
    					$tmpObj | Add-Member -MemberType NoteProperty -Name "logname" -Value $logname.ToString()
    					$tmpObj | Add-Member -MemberType NoteProperty -Name "Size" -Value $log.FileSize
                        $tmpObj | Add-Member -MemberType NoteProperty -Name "MaxEventLogSize" -Value $log.MaxFileSize
                        $tmpObj | Add-Member -MemberType NoteProperty -Name "NumORecords" -Value $numRecords
    					$tmpObj | Add-Member -MemberType NoteProperty -Name "OldestDate" -Value $date
                        if($logname -eq "Application"){
                            $tmpObj | Add-Member -MemberType NoteProperty -Name "OneDaysIISLogsize" -Value $ThisServersIISLogSizeForOneDay
                        }
                        else
                        {
                            $tmpObj | Add-Member -MemberType NoteProperty -Name "OneDaysIISLogsize" -Value ""
                        }
    					
    		            $array +=$tmpObj 	
                        
    }
    }
}

$array | export-csv $outfile -notypeinformation  