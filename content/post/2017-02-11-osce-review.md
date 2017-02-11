+++
title = "The OSCE | Cracking the Perimeter Review"
draft = false
date = "2017-02-11T13:05:48-08:00"

+++

![ctp](../img/ctp-boxes-small.png#floatright)
I recently took the [CTP course](https://www.offensive-security.com/information-security-training/cracking-the-perimeter/) by Offensive Security and passed the OSCE exam. Now there are a few dozen [reviews](https://www.google.com/search?q=osce+exam+review) on this thing, but I'll add my own take here anyway. 

### Pre Course

You can't just register for the CTP - you need to solve a small challenge first: http://fc4.me/. When I initially thought about taking this course, part of this challenge was beyond me. But to quote [g0tmi1k](https://blog.g0tmi1k.com/2013/08/cracking-perimeter-ctp-offensive/ ): 

 > "There isn't any shame in not being able to complete this. It simply means you're not ready... yet! If you look up the solution online, you're just cheating yourself and wasting both time and money. It's been put there for a reason. Offsec is trying to protect you from yourself (in their own frustrating but necessary way!)."

And so I began my prep for the course. Corelan's [exploit dev tutorials](https://www.corelan.be/index.php/2009/07/19/exploit-writing-tutorial-part-1-stack-based-overflows/), Fuzzysec's [tutorials](https://www.fuzzysecurity.com/tutorials.html), and Stephen Bradshaw's [Vulnserver](http://www.thegreycorner.com/2010/12/introducing-vulnserver.html) helped immensely. Having gone through, played with, and poked at that material, I was able to solve the initial challenge and set a course start date.

### Course

The CTP syllabus is available [here](https://www.offensive-security.com/documentation/cracking-the-perimiter-syllabus.pdf) and gives a high level overview of what is covered. If you've taken the OSCP, it doesn't cover nearly as much ground, and is much more focused on the following topics.

**Web Application Angle** - The two modules covered here are a bit more complex that what you'd find in the OSCP but nothing too ground breaking. XSS, CSRF, LFI are covered but the scenarios are more real world than trivial examples I've seen elsewhere. Still valuable.

**Backdooring and AV Bypass** - I hadn't done this before and thought these modules were pretty fun. I fully realized that AV today is ... less than perfect and is really only catching the known bad. There are a billion ways to bypass even heuristics, especially if you can write just the smallest amount of code.

**0 Day Angle** - These modules cover fuzzing and the infamous HP Openview NNM exploit. NNM is usually what people talk about when they bring up the course. Muts actually covers this crazy exploit at Defcon 16 in this [video](https://www.youtube.com/watch?v=gHISpAZiAm0). This module makes up a larger portion of the course work and was pretty enjoyable. I must say having read *Hacking: The Art of Exploitation* and having some of those code samples available was also helpful to me here.

**Networking Angle** - Spoofing SNMP and GRE tunnels. I barely recall this module. Although though seeing how devastating (and relatively straight forward) a MiTM attack can be at the infrastructure level was certainly eye opening.

I learned a ton in this course. Definitely realized that the amount I don't know about exploit development is pretty staggering. This is supposed to be an intermediate course but looking at the amount of research out there, some of this feels pretty entry level as the heap and ROP aren't even mentioned. That said, the scope of the CTP is a bit wider than just exploit development, so maybe that's a bit unfair, and I still found the course challenging. Several reviews do mention the dated material and that may be true, but I felt what was taught was entirely foundational. A person must walk before they run and the CTP course does an excellent job doing just that.

Of course even excellent courses can be improved, and one thing that gave a bit of dissatisfaction was the lack of Extra Mile exercises going through the course like the OSCP course did. It seemed you could complete a module easily enough following the directions, have an basic starting point of where to research more, and then it was off to the next chapter. And perhaps this is by design, but I think I learned more while practicing for the exam than during the course itself. The course material gave me starting points, skeletons to work from, ideas to use, and from there I was able to fill in the blanks through additional research and practice.


### Exam

The 48 hour exam was not easy. The number of times I thought I was completely screwed, unprepared, and guaranteed failure was more than a few. And it was still somehow enjoyable! In general I found myself realizing I needed to think laterally, to take a step back and look at the big picture. The feeling of accomplishment after hours working through various potential paths and finally succeeding is hard to beat. I felt the OSCE exam had the perfect level of challenge and frustration without that feeling of impossibility. While everything on the exam is covered in the the course in principle, OffSec will never let you simply follow the directions to success. They teach principles and techniques and let you apply them creatively.

I spent around sixteen hours on the exam the first day with quick breaks for coffee and lunch and forced myself to go to sleep before 1 am. I got around seven hours of sleep and then did another sixteen hours the next day before successfully completing all the challenges for full points. I strongly recommend getting a good night's rest the first night and come back the next day planning on working late if need be.

All in all, the CTP course was informative and valuable and the exam enjoyably challenging. Highly recommended.

### Helpful Resources

* [Web - Jason Haddix Bug Hunting Guide](https://github.com/jhaddix/tbhm)
* [AV Bypass Techniques](http://packetstorm.foofus.com/papers/virus/BypassAVDynamics.pdf)
* [AV Bypass and PE Backdoors](https://pentest.blog/art-of-anti-detection-2-pe-backdoor-manufacturing/)
* [AV Bypass - Taking Back Netcat](https://packetstormsecurity.com/papers/virus/Taking_Back_Netcat.pdf)
* [Fuzzing - Awesome-Fuzzing on Github](https://github.com/secfigo/Awesome-Fuzzing)
* [Fuzzing - Vulnserver Intro](http://resources.infosecinstitute.com/fuzzing-vulnserver-discovering-vulnerable-commands-part-1/)
* [Fuzzing and Exploit Dev - Vulnserver](http://www.thegreycorner.com/2010/12/introducing-vulnserver.html)
* [Exploit Dev - Corelan Tutorials](https://www.corelan.be/index.php/2009/07/19/exploit-writing-tutorial-part-1-stack-based-overflows/)
* [Exploit Dev - Corelan Wallpaper](https://raw.githubusercontent.com/corelan/wallpapers/master/corelan_wallpaper_dark_1920-1080.png)
* [Exploit Dev - FuzzySec Windows Exploit Development Tutorial Series](https://www.fuzzysecurity.com/tutorials.html)
* [Exploit Dev - Awesome Windows Explation on Github](https://github.com/enddo/awesome-windows-exploitation)
* [Exploit Dev - How To Shellcode](http://www.vividmachines.com/shellcode/shellcode.html)
* [Exploit Dev - Shellcode with System()](http://www.gosecure.it/blog/art/452/sec/create-a-custom-shellcode-using-system-function/)
* [Exploit Dev - ASCII Sub Generator](https://github.com/JohnTroony/HTAOE/blob/master/printable_helper.c)
