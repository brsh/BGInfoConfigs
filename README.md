BGInfo Config and Scripts

BGInfo is fantastic. The only problem with it is that it seems to be abandoned :(

In a nutshell: for Windows systems, BGInfo will print any information on your desktop wallpaper. 
If the info is available via accessible via the registry, env variable, script, or just plain text, 
BGInfo will add it right on top of whatever image you use on your desktop.

It has some problems - it starts to break down with multiple monitors; doesn't always like high-dpi... 

But it's a nice tool anyway. See www.sysinternals.com for more info

This repo holds my config and scripts to publish the following information:

* Machine name and domain
* System Comment
* Current UserName (with Domain)
* What DC validated the current user
* When the user last set his/her password (and when it needs to change)
* The OS and it's version
* The system type
* The boot time
* The time bginfo last updated
* System Make and Model
* CPU Type, speed, and count (incl. sockets, cores, and virtual procs [aka hyperthreading])
* Memory
* Drive space (incl. used and avail, format, and label)
* Network info (incl. display name, actual name, ip address, subnet, dns, dhcp [incl. lease time], and gateway)
* And the names logged in users with the time of logon

Whew.
