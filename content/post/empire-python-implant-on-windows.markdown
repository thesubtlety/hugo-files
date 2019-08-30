---
title: "Empire Python Implant on Windows"
date: 2019-08-29T16:40:37-07:00
draft: false 
---

A while back I was playing around with Empire (before it was shuttered, RIP) and bypassing a certain antivirus software. There were decent signatures for the basic powershell usage, but knowing Python was installed on the target Windows endpoints, I tried to run the Empire Python payload on Windows. It didn't work. Turns out, it's trivial to get things working again.

If you generate a basic Python stager with stock Empire, we see an initial checkin to the server

`(Empire: stager/multi/launcher) > [*] Sending PYTHON stager (stage 1) to 192.168.107.4`

But on the client, things aren't so good and the agent fails immediately with an `ImportError`.

![](/img/python-importerror.png)

After spending a few minutes looking at the python imports and googling, you can quickly see a few libraries which are only supported on Linux. But if we're not too worried about perfection we can hack these things out and get an Empire Python implant working on Windows fairly quickly.

The [pwd](https://docs.python.org/2/library/pwd.html) and [grp](https://docs.python.org/2/library/grp.html) modules are Unix specific and provide user account and password data and group information. These modules do not exist in the Windows implementation of Python and Empire isn't expecting a Windows host, so we need to fix that.

As I mentioned this is a quick and dirty implementation to get a callback so this isn't going to be pretty. To test this I simply commented out references or hardcoded values as I saw fit. In my testing I saw two files needed to be modified.
 ```
 data/agent/agent.py
 data/agent/stagers/common/get_sysinfo.py
 ```

Going through those files and replacing or updating references to those libraries with generic Python calls or simply hardcoding values seems to do the trick. Here is a simple example of replacing owner and group info with `unknown`.
![](/img/replace-grp-pwd.png)

With all the references to the `grp` and `pwd` modules fixed up, we can restart Empire, execute our listener, and generate a new stager. So now when we launch `C:\Python27\python.exe -c "import base64 etc etc"`, we get a successful callback as can be seen below.

![](/img/checkin-success.png)
![](/img/sysinfo.png)

The checkin doesn't look super pretty but it is functional! And while there are virtually no modules written specifically for Windows, at least one works along with straight up `shell` commands, uploads, and downloads for all your basic Empire C2 needs. And as an added benefit, antivirus didn't mind C2 running in Python in this case. 
![](/img/module.png)

This is a bad hack and there are a million reasons to use [a](https://github.com/cobbr/Covenant) [different](https://github.com/Ne0nd0g/merlin) [C2](https://github.com/its-a-feature/Apfell) [framework](https://github.com/BishopFox/sliver) but maybe you'll find it useful.

https://github.com/thesubtlety/Empire/tree/dev



