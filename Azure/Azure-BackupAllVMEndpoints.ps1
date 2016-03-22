$subscriptions = Get-AzureSubscription | %{ $_.SubscriptionName} | sort 

$i=0
$subscriptions | %{"[{0}]`t{1}" -f $i, $($subscriptions[$i]); $i++}

$response = Read-Host -Prompt "Select a subscription"
$subscriptionname = $subscriptions[$response]

Set-AzureSubscription -SubscriptionName $subscriptionname
Select-AzureSubscription -SubscriptionName $subscriptionname

<#
$services = Get-AzureService | %{$_.ServiceName} | sort
$s = 0
$services | %{"[{0}]`t{1}" -f $s, $($services[$s]); $s++}

$response2 = Read-Host -Prompt "Select a service"
$servicename = $services[$response2]
#>
$endpointdir = "E:\$subscriptionname`_endpoints"
mkdir $endpointdir -Force; cd $endpointdir
foreach($service in Get-AzureService){
    $vms = Get-azurevm -ServiceName $service.ServiceName
    foreach($vm in $vms){
        $endpoints = Get-AzureEndpoint -VM $vm
        $endpoints | %{$_.LBSetName, $_.LocalPort, $_.VIP, $_.ACL | FT} | FT > "$($vm.hostname)`_exp.txt"
        $endpoints >  "$($vm.hostname)`_raw.txt"     
    }
}

