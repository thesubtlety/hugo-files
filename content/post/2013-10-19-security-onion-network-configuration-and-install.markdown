---
author: noah
comments: false
date: 2013-10-19 02:41:57+00:00
layout: post
slug: security-onion-network-configuration-and-install
title: Security Onion Network Configuration and Install
wordpress_id: 96
categories:
- Security Onion
---

{{< figure caption="With apologies to The Onion" src="/img/theonion-wait-what-150x150.jpeg">}} 

I've played around with [Security Onion](http://securityonion.blogspot.com/) in the past, but have never set up my network to capture or monitor traffic. And while installing Security Onion in a VM and only looking at only local or inter-VM traffic is quite interesting, especially if a person is playing around with Metasploit or something, I wanted to see all network traffic, including my other devices. I also had a laptop lying around, not being frequently used; perfect for dedicated monitoring. So I finally got around to working through the details and going through the setup and configuration. This is a little essay on how I did that.

I don't go into much detail in the configuration of Security Onion and subsequent tools, as the [Install Wiki](http://code.google.com/p/security-onion/wiki/Installation) and [Iron Geek's video](http://www.irongeek.com/i.php?page=videos/basic-setup-of-security-onion-snort-snorby-barnyard-pulledpork-daemonlogger) do a fantastic job of that, but the following is a brief overview of how I set things up. For more background, the Security Onion [Wiki](http://code.google.com/p/security-onion/w/list) has a ton of great resources, a few of which I'll refer to in a bit, IronGeek's video walkthrough mentioned above, Doug Burk's [talk](http://www.irongeek.com/i.php?page=videos/derbycon2/2-2-9-doug-burks-security-onion-network-security-monitoring-in-minutes) and the very detailed [walkthrough](http://code.google.com/p/security-onion/wiki/IntroductionWalkthrough) on the Security Onion Wiki give tons of detailed info on setup and configuration.

Useful things before starting, depending on use case:



	
  * Dedicated machine(s) for Security Onion

	
  * Router/gateway supporting iptables

	
  * VirtualBox or VMware


**First things first, a little research**

I was somewhat at a loss on how to configure the actual network and mirror/span traffic to my laptop and Security Onion with only a simple Router. I'm running DD-WRT, but the router itself has no physical span ports. The Security Onion Wiki has a [Hardware page](http://code.google.com/p/security-onion/wiki/Hardware) which has a few links to cheap taps, but I didn't necessarily want to go that route for a simple operation like this. After watching Iron Geek's video, I was surprised I hadn't realized the solution earlier. iptables can copy all traffic (via -tee). And if you have iptables on the router, voila.

I wanted something like this. Actually, this is a dumb diagram, mostly I just wanted to use [asciiflow.com](http://www.asciiflow.com)

    
                                 +-------------+
                                 | Ze Internet |
                                 +------+------+
                                        |
                                  +-----v-----+       +------------+
                                  |  Router   |       | Security   |
                                  |           +------>| Onion      |
                                  +-----+-----+       +------------+
                                        ^     xx
                        +---------------+------+x
                        |               |       xx
                +-----+------+   +------+---+    xx
                |  Desktop   |   | Laptop   |  Tablet, Phone, etc
                +------------+   +----------+


**Let's Get Going Already!**

Still doing some prep work, I had to get Security Onion installed on my laptop and since I didn't want to lose my existing setup I chose to install in a VM. But before actually starting this goodness that is Security Onion, there is some configuration to do. We need lots of disk space, and a good amount of ram. We also need to configure our network adapter settings. As you will see while reading the Installation directions, Security Onion needs two NICs: one for monitoring, and one for management (wireless in my case). In the VM settings, I set Adapter 1 to bridge with my wired connection, and used Promiscuous Mode: All. I set Adapter 2 to bridge with my wireless connection and Promiscuous Mode: Deny. You can read a lot more info on that and VM networking settings [here.](http://www.virtualbox.org/manual/ch06.html#network_bridged.) I'm certain there are more ways to configure this, but this works.

Once your VM settings are good, you're left with actually installation and configuration. Installation itself is not too difficult if you can read directions. Lengthy and very detailed installation doc on the Security Onion [Install Wiki ](http://code.google.com/p/security-onion/wiki/Installation)as well as the [walkthrough](http://code.google.com/p/security-onion/wiki/IntroductionWalkthrough). Further configuration of tools and alerts takes more time, and some of that is nicely covered in Iron Geek's video.

Now that we have Security Onion set up and configured, lets point all the traffic towards it. As mentioned before, I'm going to do that with iptables as referenced [here](http://www.myopenrouter.com/article/10917/Port-Mirroring-Span-Port-Monitor-Port-with-iptables-on-NETGEAR-WGR614L/). In DD-WRT, this can be done via ssh or Admin > Commands and entering:

    
    iptables -A PREROUTING -t mangle -j ROUTE --gw <IP of Sec Onion box> --tee    
    iptables -A POSTROUTING -t mangle -j ROUTE --gw <IP of Sec Onion box> --tee
    
    Note: I'm actually using the host's bridged wired interface here as Security 
          Onion's monitoring interface is not assigned an IP address.


Save Firewall and test things out!

**Causing High Severity Incidents**

A simple ping from one of your devices to the router should show up, or a more sure-fire way to see an event is to go to, or _curl_ _http:/testmyids.com,_ which simply returns _uid=0(root) gid=0(root) groups=0(root). _In Snorby you should see a Sev 2 "GPL ATTACK_RESPONSE id check returned root" event, from which you can dig into further and see Payload, the Snort rule, and so on.

If so, things are good! If not, there are lots of great resources out there, not least the [Wiki pages  ](http://code.google.com/p/security-onion/w/list.)I'm off to test things out; Security Onion has a ton of tools to get to know. Good luck!
