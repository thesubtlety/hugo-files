---
author: noah
comments: false
date: 2014-12-20 22:03:29+00:00
layout: post
slug: the-oscp-penetration-testing-with-kali-linux
title: The OSCP | Penetration Testing With Kali Linux
wordpress_id: 192
categories:
- Development
- Pen Testing
---

{{< figure src="/img/pwk-box-small-128x150.png" >}}  

I've spent the last few months working through the [Penetration Testing with Kali Linux](http://www.offensive-security.com/information-security-training/penetration-testing-with-kali-linux/) course by Offensive Security which has been an awesome [learning](http://www.offensive-security.com/documentation/penetration-testing-with-kali.pdf) experience.

Much has been said on this course and I'll only briefly go over my experience and takeaways. The following reviews were helpful in making the decision to take the course.

  * Review by [g0tmi1k](https://blog.g0tmi1k.com/2011/07/pentesting-with-backtrack-pwb/)
  * Review by [recrudesce](http://fourfourfourfour.co/2014/04/20/oscp-review/)
  * Review from [Buffered.io](http://buffered.io/posts/oscp-and-me/)
  * Review from [IODigitalSec](http://www.iodigitalsec.com/offensive-security-pwb-course-and-oscp-certification-review/)
  * Review from [SecuritySift](http://www.securitysift.com/offsec-pwb-oscp/)

  <br/>
For a little preview of what's involved, check out the free [Metasploit Unleashed](http://www.offensive-security.com/metasploit-unleashed/Main_Page) course.

**Material, Course, and Exam**

After completing the 300+ page [pdf material](http://www.offensive-security.com/documentation/penetration-testing-with-kali.pdf), [muts](http://www.offensive-security.com/about-us/)-narrated videos and exercises, I
focused my attention on the lab. It is at this point, when the course turns from a more academic focus to an applied and practical nature, that the magnitude of what one is learning begins to sink in. A lab with nearly fifty diverse machines across multiple networks awaits with no further instructions. But with enumeration comes vulnerable machines, and each machine is different. Some are simple to exploit, some are difficult, some are incredibly frustrating. Every one is rewarding.

Several months later, after getting root or system access on nearly every machine, and completing a final lab penetration test report of over two hundred pages, I felt ready for the 24 hour exam. Exam day had me giddy as a little kid and went smoothly. Ten hours in I had enough points to pass but I spent another eight hours attempting to privilege escalate my way to system on one remaining machine. I eventually succumbed to exhaustion knowing I had more than enough points to pass and wishing to be functional the next day to write up my exam report.

Several days after submitting the exam report along with my final lab report, I received the much-anticipated email stating that I had passed the exam and now held my Offensive Security Certified Professional certification. I have mixed feelings about the value of certifications since just about anyone can take a test and pass. But this one - this one a person has to work for.

**A few take aways**

Document, document, document
	
  * I used Keepnote on my host machine to track everything. It's certainly not without its frustrations, but it does the job. Don't forget to back everything up!
  * Write up every machine after popping, including a summary and detailed steps along with key screenshots - you will thank yourself later. It's easy to forget, and coming back a few weeks or months later while writing up your report because you forgot something and finding your documentation didn't include some small issue is frustrating.
  
  <br/>
Enumeration is key
	
  * Every single machine is vulnerable and exploitable, it's simply a matter of finding it.
  * Reset boxes before attempting them, especially Windows. I spent many an unneeded hour working through possible exploits when a SMB service had simply
been crashed by a previous student and Metasploit would have gotten me in immediately.
  * Privilege escalation provides lessons in patience. The following resources were invaluable.
    * http://www.greyhathacker.net/?p=738
    * http://www.fuzzysecurity.com/tutorials/16.html
    * http://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/  
  
  <br/> 
Post exploitation is paramount
	
  * Multiple boxes include passwords, scripts, and log files which will provide access or attack vectors to other machines.
  * Missing one thing can lead to wasted time chasing down red herrings.

  <br/>
Utilize the admins
	
  * Make use of the admins on IRC at #offsec. While they won't give you the answer, they often ask questions which get you thinking in a certain way, and simply explaining what steps you have taken can lead to other paths for success.

  <br/>
Commit the time
	
  * The material covered in this course is not terribly difficult, but it does take practice. And practice requires time. I spent at least fifteen hours every week in the labs over the course of a few months.  

  <br/>
I think the only dissatisfaction I experienced was while working on a exploiting a machine while another student was attempting to do the same and continually reset the box wiping out any steps taken to obtain a shell for instance. This was rare, though.

Overall, this was an awesome learning experience. If you're thinking about doing it, and you have the time to dedicate, there is no question: just do it. If you actually want to learn and understand the material, rather than just memorize a bunch of information as is the case with so many other certifications, this is for you. It's affordable, lab time is easily extended, admins are almost always available, and the cost is not prohibitive.

Thanks Offensive Security and team for putting together such a fantastic course.
