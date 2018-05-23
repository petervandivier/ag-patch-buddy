# Requires -Modules {SQLServer, Pester}
function Test-SqlIsPatchReady {
<#
.DESCRIPTION
    For AOAGs on a target server, is the target in an appropriate
    to patch and reboot without causing the AG health state to degrade. 

.PARAMETER serverInstance
    Target to test. Assert that this serverInstance is not a...
        * syncronous commit partner for any AG
        * automatic failover partner for any AG
        * primary replica for any AG
#>
    [CmdletBinding()]param (
        [Parameter(Mandatory=$true)]
            [Alias('serverName','sqlServer','server')]
            [string[]]$serverInstance
    )
    
    $query_stub=@"
select
    ag.[name] as ag_name,
    replica_server_name, 
    availability_mode_desc,
    failover_mode_desc
from sys.availability_replicas
join sys.availability_groups ag on ag.group_id = availability_replicas.group_id
where replica_server_name = @@servername
    and (|WHERE_CLAUSE|);
"@
    
    Describe "Server is patch-ready." {
        foreach($s in $serverInstance){
            It "[$s] holds no SYNCHRONOUS_COMMIT roles." {
                $query=$query_stub.Replace("|WHERE_CLAUSE|","availability_mode_desc = 'SYNCHRONOUS_COMMIT'")
                @(Invoke-Sqlcmd -ServerInstance $s -Query $query).count | Should Be 0
            }
            It "[$s] holds no AUTOMATIC failover roles." {
                $query=$query_stub.Replace("|WHERE_CLAUSE|","failover_mode_desc = 'AUTOMATIC'")
                @(Invoke-Sqlcmd -ServerInstance $s -Query $query).count | Should Be 0
            }
            It "[$s] is not the PRIMARY REPLICA for any AG." {
                $query="select * from sys.dm_hadr_availability_group_states where primary_replica = @@servername;"
                @(Invoke-Sqlcmd -ServerInstance $s -Query $query).count | Should Be 0
            }
        }
    }
}
