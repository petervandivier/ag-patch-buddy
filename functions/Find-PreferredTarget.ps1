function Find-PreferredTarget {
    [cmdletbinding()]Param(
        $fromServer
       ,$agName
       ,$replicas 
       # ,$argument="FAILOVER"
    )
    
    $preference = $replicas `
    | Where-Object {
        ($PSItem.ag_name -eq $agName) -and `
        ($PSItem.server_name -ne $fromServer) -and `
        ($PSItem.is_primary -ne $true)
    } `
    | Sort-Object -Property cost -Descending `
    | Sort-Object -Property host_load `
    | Select-Object -First 1

    $preference | ForEach-Object { 
        [PSCustomObject]@{
            ag_name          = $PSItem.ag_name
            server_name      = $PSItem.server_name
            is_primary       = $PSItem.is_primary
            is_sync_commit   = $PSItem.is_sync_commit
            is_auto_failover = $PSItem.is_auto_failover
            cost             = $PSItem.cost
            host_load        = $PSItem.host_load
        }
    }
}