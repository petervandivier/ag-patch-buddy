function Get-PatchCommandIndex {
    [cmdletbinding()]Param(
        [object]$replicas
       ,[object]$primaries 
       ,[string]$hostToPatch
    )

    $cmdIndex = $replicas | Where-Object {$PSItem.server_name -eq $hostToPatch} `
    | ForEach-Object {
        $agName = $PSItem.ag_name
            $preferredTarget = (Find-PreferredTarget `
            -fromServer $hostToPatch `
            -agName $agName `
            -replicas $replicas
        ).server_name
        $primaryReplica = ($primaries | Where-Object {$PSItem.ag_name -eq $agName}).server

        if($PSItem.value -eq 0){
            # replica is currently async, manual for $agName...
            # ...nothing to do here, but fill in the placeholder
            [PSCustomObject]@{
                OrderMajor    = 2
                OrderMinor    = 1
                AgName        = $agName
                ExecuteFrom   = $primaryReplica
                ExecuteAt     = $preferredTarget
                CommandName   = "_PASS_"
                Command       = "/* nothing to do here... */"
            }
        }else{
            $cmdType = "MAKE_SYNC_AUTO"

            $cmd = (Get-PrePatchCommand `
                -cmdType $cmdType `
                -agName $agName `
                -cmdTarget $preferredTarget 
            ).Command

            [PSCustomObject]@{
                OrderMajor    = 2
                OrderMinor    = 1
                AgName        = $agName
                ExecuteFrom   = $primaryReplica
                ExecuteAt     = $preferredTarget
                CommandName   = $cmdType
                Command       = $cmd
            }
            
            $cmdType = "MAKE_MANUAL_ASYNC"

            $cmd = (Get-PrePatchCommand `
                -cmdType $cmdType `
                -agName $agName `
                -cmdTarget $primaryReplica 
            ).Command

            [PSCustomObject]@{
                OrderMajor    = 2
                OrderMinor    = 2
                AgName        = $agName
                ExecuteFrom   = $primaryReplica
                ExecuteAt     = $primaryReplica
                CommandName   = $cmdType
                Command       = $cmd
            }
        } 
    }
    $cmdIndex | ForEach-Object {
        [PSCustomObject]@{
            OrderMajor  = $PSItem.OrderMajor
            OrderMinor  = $PSItem.OrderMinor
            AgName      = $PSItem.AgName
            ExecuteFrom = $PSItem.ExecuteFrom
            ExecuteAt   = $PSItem.ExecuteAt
            CommandName = $PSItem.CommandName
            Command     = $PSItem.Command
        }
    }
}