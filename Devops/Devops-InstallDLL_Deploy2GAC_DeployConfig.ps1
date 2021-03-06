## deploy gacutil
## deploy DLL to folder:  d$\disenza\WEB_req_jammer_Build\WEB.reqjammer.dll
$srcDLL = "\\ctyfs-a01s\dsw\Misc\BRBdll\WEB.reqjammer.dll"
$srcGAC = "\\ctyfs-a01s\dsw\Misc\BRBdll\gacutil.exe"
$configsource = "\\ctyfs-a01s\dsw\mypow\DS\IIS7\web.config"

$servers = gc @("\\ctyfs-a01s\dsw\mypow\testservers.txt")

foreach($srv in $servers){   
    
    $networksrv = "\\"+$srv+"\d$\disenza\WEB_req_jammer_Build\"
    mkdir $networksrv
    copy-item $srcDLL -destination $networksrv -recurse -force
    copy-item $srcGAC -destination $networksrv -recurse -force
    cd E:\disenza\scripts\
    .\psexec.exe /acceptEula \\$srv E:\disenza\WEB_req_jammer_Build\gacutil.exe /nologo /i E:\disenza\WEB_req_jammer_Build\WEB.reqjammer.dll
    #item to remove:  
    $rmGACTool = $networksrv+"gacutil.exe"
    Remove-Item  $rmGACTool -Force
    $json = "\\"+$srv+"\c$\WEB.reqjammer.json"
    if(!(test-path $json)){
        new-item $json -type file;         
    } 
    write-host "setting permissions for $($json)"
    ## now apply the right permissions for the iiswpg:
    $num = ($srv.split('a')[1])
    $numlower = ([string]([int]$num-1))+([string]$num)
    $numupper = ([string]([int]$num))+[string]([int]$num+1)
    foreach($num in @($numlower,$numupper)){
        $user = "ETDsoya\a$($num)_IISWPG"
        write-host $user -f red
        CMD.EXE /C "Icacls $($json) /GRANT $($user):f"
    }
        <#$acl = Get-Acl $json
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("ETDsoya\a2930_IISWPG","ReadAndExecute","ContainerInherit.ObjectInherit","None","Allow")
        $acl.SetAccessRule($rule);
        
        foreach($right in @('ReadAndExecute','Write','Modify')) {
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone",$right, "ContainerInherit, ObjectInherit", "None", "Allow")
            $acl.SetAccessRule($rule);
        }
        Set-Acl $webRoot $acl#>
    <#
    #deploy source config
    $networkWconfig = "\\"+$srv+"\c$\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web.config"
    write-host "Deploying config now to: $networkWconfig"
    copy-item $configsource -destination $networkWconfig
    #>
}



