$vm  = "sushifig-sql-wi"
  $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $vm)
    $RegKey= $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Virtual Machine\\Guest\\Parameters")
    $RmHost = $RegKey.GetValue("HOSTName")
    $RmPHost = $RegKey.GetValue("PhysicalHostName")

    $RmHost

    $RmPHost