$subscriptions = Get-AzureSubscription | %{ $_.SubscriptionName} | sort 

$i=0
$subscriptions | %{"[{0}]`t{1}" -f $i, $($subscriptions[$i]); $i++}

$response = Read-Host -Prompt "Select a subscription"
$subscriptionname = $subscriptions[$response]

Set-AzureSubscription -SubscriptionName $subscriptionname
Select-AzureSubscription -SubscriptionName $subscriptionname

$services = Get-AzureService | %{$_.ServiceName} | sort
$s = 0
$services | %{"[{0}]`t{1}" -f $s, $($services[$s]); $s++}

$response2 = Read-Host -Prompt "Select a service"
$servicename = $services[$response2]


$vmname = Read-Host -prompt "sushiwaf-1st-z, sushiwaf-1st-y, sushiwaf-1sthourly-x, sushiwaf-1sthourly-w, baconwaf-1sthourly-s, baconwaf-1sthourly-t" #"sushiwaf-1st-z"

$vm = Get-AzureVm -ServiceName $servicename -Name $vmname

$endpoints = Get-Azureendpoint -VM $vm
$endpoints | %{$_.LBSetName, $_.LocalPort, $_.VIP, $_.ACL | FL} | FL > "$vmname`_exp.txt"

$endpoints > "$vmname.txt"
