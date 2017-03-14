+++
title = "Informacast Singlewire Insecure JMX Config to RCE"
draft = false
date = "2017-03-13T23:17:52-07:00"

+++

I recently came across a good reminder to double check listening ephemeral ports. The organization in question was using the [Informacast Singlewire Desktop Notifier](https://www.singlewire.com/informacast-desktop-notifier.html) v2.0 application. It allows organizations "to display a pop-up window on top of other running applications to inform users of important information" or to send desktop alerts to users in geographic regions. 

After some enumeration, it looked like it was exposing a [JMX Remote management](https://docs.oracle.com/javase/7/docs/technotes/guides/management/agent.html) port of we'll say port 42424. Nmap won't identify the service version in a normal scan, but if you request `--version-all`, you should see the port listed as rmiregistry.

`#nmap -p 42424 -sV --version-all 172.16.42.42`
```
PORT 	  STATE     SERVICE 	VERSION
42424/tcp open	    rmiregistry	Java RMI
```

You can connect to the service legitimately with `jconsole` available in Kali to verify the service as well. This will get you Java debug info, the hostname, username, and the ability to invoke various functions with `jconsole ip.add.re.ss:42424`. Nmap also has the `rmi-dumpregistry` script to gather more information.

![jconsole](/img/s1.png)

As we'll later discover, the application was running with some suspect options:
```
-Dcom.sun.management.jmxremote.port=42424 
-Dcom.sun.management.jmxremote.authenticate=false 
-Dcom.sun.management.jmxremote.ssl=false 
com.berbee.ippaging.desktop.SpelDesktopAgent
```

Unfortunately for this organization, the fine folks at Optiv (Braden Thomas) had done a bit of [research](https://www.optiv.com/blog/exploiting-jmx-rmi) extending an insecure [Java RMI configuration](https://www.rapid7.com/db/modules/exploit/multi/misc/java_rmi_server) exploit which led to the creation of the [Java JMX Insecure Configuration](https://www.exploit-db.com/exploits/36101/) Metasploit module to abuse this insecure configuration. With authentication disabled and an application using poor secure coding practices, this exploit respectfully offers up a user shell.

```
#msfconsole
>use exploit/multi/misc/java_jmx_server
..set RHOST and LPORT
>exploit
```

![jconsole](/img/s2.png)

And since this was deployed to the entire Windows fleet, all machines had this nice little backdoor installed. Fortunately this product version is end of life'd but there is no mention of the issue in any Informacast documentation. The word I heard back from the vendor was to "update to the latest version" which apparently has no Java dependencies.

[Bytes Darkly](http://bytesdarkly.com/2016/01/know-your-tools-cve-2015-2342-ioc-and-metasploit/) has some IOCs written up on the Metasploit payload which are worth checking out as well.

## Resources

* https://www.optiv.com/blog/exploiting-jmx-rmi
* http://bytesdarkly.com/2016/01/know-your-tools-cve-2015-2342-ioc-and-metasploit/
