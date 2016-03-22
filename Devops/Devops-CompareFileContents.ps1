$yesterdayfolderfile = "C:\Domains\_20140402\A\ADAMSANDRE_vbwr.com.txt"

$todayfolderfile = "C:\Domains\_20140402\A\ADAMSANDRE_vbwr.com.txt"
$Location = "c:\Domains\testdiff.txt"

### this is not so good
Compare-Object (Get-Content $yesterdayfolderfile) (Get-Content $todayfolderfile) -SyncWindow 1 | where {$_.SideIndicator -eq "<="} | formprimlist | Out-File $Location

