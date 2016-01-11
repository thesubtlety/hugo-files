---
author: noah
comments: false
date: 2013-05-07 01:43:15+00:00
layout: post
slug: kippo-on-the-raspberry-pi
title: Kippo on the Raspberry Pi
wordpress_id: 74
categories:
- Honeypot
- Kippo
- Raspberry Pi
tags:
- honeypot
- Kippo
- raspberry pi
---

I recently bought a Raspberry Pi and installed [Arch Linux ARM](http://archlinuxarm.org/platforms/armv6/raspberry-pi#qt-platform_tabs-ui-tabs2) on it. I came across a rather amusing blog post of someone using the [honeypot](https://en.wikipedia.org/wiki/Honeypot_(computing)) [Kippo](https://code.google.com/p/kippo/) and thought what fun. See [here](http://www.iwatchedyourhack.org/) to watch elite hackers and their mad skillz. That's the great thing about Kippo - it records user sessions for playback.

Anyways, this post basically walks through what I did to get Kippo and [kippo-graph](http://bruteforce.gr/kippo-graph) up and running on my RPi. This isn't a walk-you-through-every-step guide, so if you're following along your mileage may vary. Of course, the [Wiki pages](https://code.google.com/p/kippo/w/list) over on Google Code are a good place to start. Or [here](http://bruteforce.gr/installing-kippo-ssh-honeypot-on-ubuntu.html). Or [here](http://www.ctrl-alt-del.cc/2010/07/making-new-friends-with-kippo.html). Everyone's done this! But without further adieu...

Install all the dependencies. You need svn to pull the source which is easy enough, and Kippo has several dependencies as well. These would Python 2.5+, Twisted 8+, PyCrypto, and Zope-interface. Don't do like I did and install the default Python 3+. Apparently there was a change to the print statement (become a function) and I was getting syntax errors. Downgraded and all was peachy. Rename the kippo.cfg.dist file to kippo.cfg and make changes as you please.

Kippo runs on port 2222 by default and you can probably leave this as is. There are a [couple](https://code.google.com/p/kippo/wiki/MakingKippoReachable) methods to get Kippo running on port 22, and I chose to use iptables. I'll come back to that. I also wanted to be able to access my RPi using SSH, and if we have iptables pointing port 22 to Kippo, well that's no good. Let's `sudo vi /etc/ssh/sshd_config ` and change the default port to something else, like 2220 or something and restart sshd.

Next, we want packets destined for port 22 to be redirected to Kippo. This can be accomplished using the iptables command

    
    ~#iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222


And saving with ` iptables-save > /etc/iptables/iptables.rules `. You may need to ` sudo -i` first as piping to output runs as the current user. Kippo isn't running as root is it? No, of course not, you wouldn't do that.

Cool. Now start Kippo. Running netstat on the RPi should show Kippo (seen below as python2) listening on 2222 and SSH listening on 2220.

    
    [pi@myRPi kippo]$ sudo netstat -antp
    Active Internet connections (servers and established)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
    tcp        0      0 0.0.0.0:2220           0.0.0.0:*               LISTEN      113/sshd            
    tcp        0      0 0.0.0.0:2222           0.0.0.0:*               LISTEN      266/python2                          
    tcp        0      0 192.168.1.229:2222     192.168.10.199:42451    ESTABLISHED 208/sshd: pi [priv]


And running nmap on my RPi from my desktop shows that port 22 is also listening, so we know iptables is properly accepting and forwarding packets. Note the ssh-hostkey is the same for both ports 22 and 2222.

    
    np@whereami [03:26:17] [~] 
    -> % sudo nmap -A -sS myRPi -p 1-2222
    Starting Nmap 6.25 ( http://nmap.org ) at 2013-05-04 15:26 EDT
    Nmap scan report for myRPi (192.168.10.229)
    Host is up (0.00045s latency).
    Not shown: 22220 closed ports
    PORT      STATE SERVICE VERSION
    22/tcp    open  ssh     OpenSSH 5.1p1 Debian 5 (protocol 2.0)
    |_ssh-hostkey: 1024 50:d3:4e:ac:6d:2e:94:66:ac:02:ce:9b:f9:b7:cd:69 (RSA)
    2222/tcp open  ssh     OpenSSH 5.1p1 Debian 5 (protocol 2.0)
    |_ssh-hostkey: 1024 50:d3:4e:ac:6d:2e:94:66:ac:02:ce:9b:f9:b7:cd:69 (RSA)
    2220/tcp open  ssh     OpenSSH 6.2 (protocol 2.0)
    | ssh-hostkey: 1024 e3:9c:96:42:e6:4c:f0:53:d4:44:31:cd:f3:e5:35:89 (DSA)
    | 2048 85:38:a1:25:da:9f:8d:d7:24:f7:ed:37:ae:76:e3:43 (RSA)
    |_256 39:34:f2:83:ac:a4:43:ff:d0:4b:9d:3b:ac:d0:bf:48 (ECDSA)
    MAC Address: B8:27:EB:33:BE:85 (Raspberry Pi Foundation)


You can test logging into both regular SSH via ` ssh -p 2220 user@RPi` or to Kippo using `ssh root@RPi` which will default to port 22.

Not quite finished, though. We need to make port 22 available to the world, and this can be accomplished by port forwarding at the router. My RPi has a static IP address, so logging into my router, I simply forwarded port 22 to my RPi's port 22. If you want to check and see if this is working, something like [You Get Signal](http://www.yougetsignal.com/tools/open-ports/) can tell you if it's open or not.

Kippo's logs can be viewed in the installation folders /log/kippo.log. This is raw output, though and I wanted something prettier. As I alluded to earlier, I used [Kippo-graph](http://bruteforce.gr/kippo-graph). Kippo-graph requires running an apache server, MariaDB (MySQL drop-in), and PHP, so those will need installed as well. I used the mysql_secure_installation and [this guide](http://bruteforce.gr/logging-kippo-events-using-mysql-db.html) for basic configuration of the database and Kippo's configuration. And this [fantastic Arch guide](https://wiki.archlinux.org/index.php/LAMP) to get Apache and PHP configured. Pay attention to the PHP config file and ensure the correct modules are enabled. I missed un-commenting and was getting a blank screen when I tried to generate graphs. Also note that graphs will appear broken until the database has something captured. 

Once everything is configured, restart the httpd service and browse to wherever you've hosted those files, e.g. `http://myRPi:80` and peruse away. Of course there won't be much to peruse initially, but all in good time my friend. 

Now to let this thing run for a bit and see what it catches!
