$mem = Get-WmiObject -class Win32_PerfRawData_PerfOS_Memory -Property AvailableKBytes
$availKB = $mem.AvailableKBytes
$os = Get-WmiObject -class Win32_OperatingSystem -Property TotalVisibleMemorySize
$totalKB = $os.TotalVisibleMemorySize

$pct_avail = (($totalKB-$availKB)/$totalKB)*100
write-host $pct_avail 

if($pct_avail -gt "10"){

    write-host "got here"
}
else {
    write-host "2"
}