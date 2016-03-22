#add credentials
add-azureaccount

#get the subscriptions, and list them.  Let the user choose which subscription they want to work with
$subs = Get-AzureSubscription | sort SubscriptionName
$cnt = 0
foreach ($sub in $subs){
    Write-Host "$cnt.  $($sub.SubscriptionName) "
    $cnt = $cnt + 1
}
[int]$index = Read-Host "Enter the number for the subscription you want to work with"
$mysubription = $subs.SubscriptionName[$index]
Select-AzureSubscription -SubscriptionName $mysubription

#Get the search dates
$startDT = Read-Host "Enter the start date you want to search, in the format mm/dd/yyyy"
$endDT =  Read-Host "Enter the end date you want to search, in the format mm/dd/yyyy"
#$startDT = "3/1/2015"
#$endDT = "4/4/2015"

#Loops through the services
$svcs = Get-AzureService
#$svcs = Get-AzureService "bald-sushiICE-DIM"
foreach ($svc in $svcs) {
    Write-Host "Processing service [ $($svc.ServiceName) ]..." -ForegroundColor Cyan

    #Get the VMs in the current service
    $vms = Get-AzureVM -ServiceName $svc.ServiceName
    #if the service has VMs, then we'll print out the VMs, and then check to see if there was any maintenance activities in this service
    if ($vms.Count -gt 0){
        Write-Host "VMs in service..."
        foreach ($vm in $vms) {
            Write-Host "  - $($vm.Name) "
        }
        Write-Host "Checking for maintenance..."
        $svc | get-azuredeploymentevent –StartTime $startDT -EndTime $endDT
    }
    else {
        Write-Host "  --> No VMs in service [ $($svc.ServiceName) ]" -ForegroundColor Yellow
    }
}