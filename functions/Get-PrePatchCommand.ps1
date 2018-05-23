function Get-PrePatchCommand {
    [cmdletbinding()]Param(
        $cmdType
       ,$agName
       ,$cmdTarget 
    )

#region SqlDictionary

$cmdStub_Failover="alter availability group [|AG_NAME|] failover;"
$cmdStub_MakeSyncAuto=@"
alter availability group [|AG_NAME|] modify replica on '|SERVER_NAME|' with ( availability_mode = synchronous_commit );
alter availability group [|AG_NAME|] modify replica on '|SERVER_NAME|' with ( failover_mode = automatic );
"@
$cmdStub_MakeManualAsync=@"
alter availability group [|AG_NAME|] modify replica on '|SERVER_NAME|' with ( failover_mode = manual );
alter availability group [|AG_NAME|] modify replica on '|SERVER_NAME|' with ( availability_mode = asynchronous_commit );
"@
$cmdStub_UnhealthyState=@"
raiserror('|AG_NAME| will be in an unhealthy state.',16,1);
"@

#endregion
    
    if($cmdType -eq "FAILOVER"){
    }
    if($cmdType -eq "MAKE_SYNC_AUTO"){
        if($cmdTarget -eq $null){
            $cmd = $cmdStub_UnhealthyState.Replace("|AG_NAME|","$agName")
        }else{
            $cmd = $cmdStub_MakeSyncAuto.Replace("|AG_NAME|","$agName").Replace("|SERVER_NAME|","$cmdTarget")
        }
    }
    if($cmdType -eq "MAKE_MANUAL_ASYNC"){
        $cmd = ($cmdStub_MakeManualAsync).Replace("|AG_NAME|","$agName").Replace("|SERVER_NAME|","$cmdTarget")
    }

    [PSCustomObject]@{
        Command = $cmd
    }
}