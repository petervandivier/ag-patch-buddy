function Resolve-Environment {
    [cmdletbinding()]Param(
        [string[]]$hosts
    )

    $primaries = Get-Ags -serverInstance $hosts | Select-Object ag_name, server

    $replicas = $primaries | ForEach-Object {
        Get-Replicas -ag_name $PSItem.ag_name -serverInstance $PSItem.server `
        | Select-Object `
            ag_name, `
            server_name, `
            is_primary, `
            is_sync_commit, `
            is_auto_failover
    }

    $replicas | ForEach-Object {
        $value = (`
             ($PSItem.is_primary       * 100) `
            +($PSItem.is_auto_failover * 10 ) `
            +($PSItem.is_sync_commit)
        )
        $PSItem | Add-Member -MemberType NoteProperty -Name "value" -Value $value
    }

    $hosts = $replicas | Group-Object -Property server_name `
    | ForEach-Object {
        New-Object psobject -Property @{
            name = $PSItem.name
            load = ($PSItem.Group | Measure-Object value -Sum).Sum
        }
    }

    $replicas | ForEach-Object {
        $r = $PSItem.server_name
        $host_load = ($hosts | Where-Object {$PSItem.name -eq $r}).load
        $PSItem | Add-Member -MemberType NoteProperty -Name "host_load" -Value $host_load
    }

    [PSCustomObject] @{
        hosts     = $hosts
        replicas  = $replicas
        primaries = $primaries
    }
}
