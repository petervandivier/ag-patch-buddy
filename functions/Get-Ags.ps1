# Requires -Modules {SQLServer}
function Get-Ags {
    [CmdletBinding()]param (
        [Parameter(Mandatory=$true)]
            [Alias('serverName','sqlServer','server')]
            [string[]]$serverInstance
    )

    $query=@"
select ag.group_id
    ,ag.[name] as ag_name
    ,s.role_desc
    ,ag.is_distributed
    ,s.operational_state_desc
    ,s.connected_state_desc
    ,s.recovery_health_desc
from sys.availability_groups ag
join sys.dm_hadr_availability_replica_states s on s.group_id = ag.group_id
where s.[role] = 1;    
"@
  
    foreach($s in $serverInstance){
        Invoke-Sqlcmd -ServerInstance $s -Query $query | ForEach-Object { 
            [PSCustomObject]@{
                server = "$s"
                group_id = $PSItem.group_id
                ag_name = $PSItem.ag_name
                role_desc = $PSItem.role_desc
                is_distributed = $PSItem.is_distributed
                operational_state_desc = $PSItem.operational_state_desc
                connected_state_desc = $PSItem.connected_state_desc
                recovery_health_desc = $PSItem.recovery_health_desc
            }
        }
    } 
}
