# AOAG Patch Buddy

> Boy howdy AOAG is a nifty technology! I can reboot my secondary like mad and never eat into my uptime! I'm gonna set this up for all my DBs!

_...one quarter later..._

> Hmm... This is more complicated now. I have to do multiple failovers each time I want to reboot. Still, it's better than downtime. Surely adding another replica is only going to make my life better!

_...some time later..._

> What have I done...

In an multi-AG farm, you _may_ not have a deployment topology that is immediately human understandable. As you add AGs & replicas for each totally legit use case, the complexity of a low-impact reboot of any host increases rapidly. These scripts are intended to assist the task of setting an arbitrary host into a "safe" state and auditing the "safe" state before you take any patch or reboot action that may make the replica unhealthy to the cluster.
