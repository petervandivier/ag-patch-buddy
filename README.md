# AOAG Patch Buddy

> Boy howdy AOAG is a nifty technology! I can reboot my secondary like mad and never eat into my uptime! I'm gonna set this up for all my DBs!

_...one quarter later..._

> Hmm... This is more complicated now. I have to do multiple failovers each time I want to reboot. Still, it's better than downtime. Surely adding another replica is only going to make my life better!

_...some time later..._

> What have I done...

In an multi-AG farm, you _may_ not have a deployment topology that is immediately human understandable. As you add AGs & replicas for each totally legit use case, the complexity of a low-impact reboot of any host increases rapidly. These scripts are intended to assist the task of setting an arbitrary host into a "safe" state and auditing the "safe" state before you take any patch or reboot action that may make the replica unhealthy to the cluster.

# Example

The below sample represents a 4-server (A,B,C,D) topology with 4 AGs (1,2,3,4)

```ascii-art
      +-----+-----+-----+-----+
      |  1  |  2  |  3  |  4  |
+-----+-----+-----+-----+-----+
| A   | SA* | SA* |     |     |
+-----+-----+-----+-----+-----+
| B   | SA  | SA  | SA* |     |
+-----+-----+-----+-----+-----+
| C   | AM  |     | SA  | SA* |
+-----+-----+-----+-----+-----+
| D   | AM  |     | AM  | SA  |
+-----+-----+-----+-----+-----+
```

* `SA` denotes a synchronous commit, automatic failover secondary replica
* `AM` denotes an asynchronous commit, manual failover secondary replica
* `SA*` denotes the primary replica

In order to patch any given host, we need to be sure that it is not an `SA` member in any AG.

For example, to patch server `C`, we might take the following actions

* Set `AG3 - D` to be a synchronous-automatic partner and set `AG3 - C` to async-manual
* Failover `AG4` to replica `D` & set `AG4 - C` to async-manual
	* Note that `AG4` will be in an unhealthy state during the patch window

Following these actions, we hope the farm will look like the following.

```ascii-art
                       unhealthy
      +-----+-----+-----+-----+
      |  1  |  2  |  3  | <4> |
+-----+-----+-----+-----+-----+
| A   | SA* | SA* |     |     |
+-----+-----+-----+-----+-----+
| B   | SA  | SA  | SA* |     |
+-----+-----+-----+-----+-----+
| C   | AM  |     | AM  | AM  | <-- patch ready
+-----+-----+-----+-----+-----+
| D   | AM  |     | SA  | SA* |
+-----+-----+-----+-----+-----+
```

# Usage

Clone into a folder and import (note we rename on clone, see #3 for why).

```powershell
git clone git@github.com:petervandivier/ag-patch-buddy.git AOAGPatchBuddy
Import-Module .\AOAGPatchBuddy
```

`Test-SqlIsPatchReady` - after setting all AGs to a safe state, run a couple quick pester checks to assert the server is ok to patch.

`Resolve-Environment` - takes an array of hosts and enumerates AGs on these servers and their respective partnership roles  

`Get-PatchCommandIndex` - takes the output of `Resolve-Environment` & evaluates an option set for an input `host` 
