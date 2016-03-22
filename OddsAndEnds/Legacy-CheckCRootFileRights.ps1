$servers = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -notmatch '(sushiEGG|sushiQQ5|bacon)'} | select -Expand Name | sort -Descending
#$servers = $servers -join ','

foreach($vm in $servers){

    $json = "\\$vm\c$\Bds.RequestBlocker.json"
    if(test-path $json){
        write-host $json -f Yellow
        write-host (get-item $json).Length

        $acl = get-acl $json
        $acl.Access | %{ write-host $_.identityReference.Value : $_.FileSystemRights }
    }
    <#break;
    
    #>
}


<#test specific file:
$t = get-acl \\sushiGUM-SGC-02\c$\Bds.RequestBlocker.json
$t.Access | %{ write-host $_.identityReference.Value : $_.FileSystemRights} # | FL #>
