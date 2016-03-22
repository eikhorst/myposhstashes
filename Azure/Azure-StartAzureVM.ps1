# This script will get executed in response to a monitor alert.  To learn
# about the variables that are available, press the Variables button.  You
# can write any kind of script that you'd like here.  This script is run
# using your system's PowerShell interpreter.
# 
# Warning: Don't show a user interface from the script (ie don't call
# MsgBox or any other method that shows a user interface) since this will
# cause the script to freeze when running from within the monitoring 
# service.
# 
#Example:
#$alertText = "Computer: " + $act.Machine + "  Type: " + $act.MonitorType + "  Title: " + $act.MonitorTitle + "  Info: " + $act.Details 

Get-AzureService | Get-AzureVM | FormprimTable –auto "ServiceName","Name","InstanceStatus"

$Service = "bald-sushihelix"
$VM = $act.Machine

$vmstatus = (get-azurevm -ServiceName $Service -Name $VM).Status

if($vmstatus -ne "ReadyRole"){
    Start-AzureVM -ServiceName $Service -Name $VM 
}

# Now pass $alertText to your own or third-party objects.