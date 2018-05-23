# Requires -Modules {SQLServer}
function get-replicas {
    [CmdletBinding()]param (
        [Parameter(Mandatory=$true)]
            [Alias('ag','agName','ag_name')]
            [string]$availabilityGroup
       ,[Parameter(Mandatory=$true)]
            [Alias('serverName','sqlServer','server')]
            [string]$serverInstance 
    )
    <# TODO fast-fail for bad target
    Requires -Modules {nettcpip}
    if ((Test-NetConnection -ComputerName $serverInstance -Port 1433).TcpTestSucceeded -ne $true) {
        Write-Host "Connection to SQL Server on $($serverinstance):1433 could not be resolved." -ForegroundColor Red
        return
    }
    #>

    $query=@"
select ag.group_id
    ,ag_name                   = ag.[name]
    ,server_name               = ar.replica_server_name
    ,ar.[endpoint_url]
    ,is_primary                = iif(ar.replica_server_name = @@servername, 1, 0)
    ,is_sync_commit            = ar.[availability_mode]
    ,is_auto_failover          = convert(int, ar.[failover_mode]^1)
    ,is_primary_desc           = iif(ar.replica_server_name = @@servername, 'PRIMARY_REPLICA', 'SECONDARY_REPLICA')
    ,ar.availability_mode_desc
    ,ar.failover_mode_desc
    ,ar.seeding_mode_desc
 from sys.availability_groups ag
 join sys.availability_replicas ar on ar.group_id = ag.group_id
 where ag.[name] = '$availabilityGroup';
"@

    Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query  -ErrorAction SilentlyContinue `
    | ForEach-Object {
        [PSCustomObject]@{
            group_id               = $PSItem.group_id
            ag_name                = $PSItem.ag_name
            server_name            = $PSItem.server_name
            endpoint_url           = $PSItem.endpoint_url
            is_primary_desc        = $PSItem.is_primary_desc
            availability_mode_desc = $PSItem.availability_mode_desc
            failover_mode_desc     = $PSItem.failover_mode_desc
            seeding_mode_desc      = $PSItem.seeding_mode_desc 
            is_primary             = $PSItem.is_primary        
            is_sync_commit         = $PSItem.is_sync_commit 
            is_auto_failover       = $PSItem.is_auto_failover     
        }
    }     
}