---
author: noah
comments: true
date: 2012-09-15 22:22:40+00:00
layout: post
slug: on-the-dumbest-ideas-in-computer-security
title: On the Dumbest Ideas in Computer Security
categories:
- careers 
---

The other day I came across an article by [Marcus J Ranum](http://en.wikipedia.org/wiki/Marcus_J._Ranum) on [the six dumbest ideas in computer security](http://www.ranum.com/security/computer_security/editorials/dumb/index.html) which were very simple yet struck me as profound. I'll summarize them here for future reference.

1) Default Permit


Back when computer networks were still in their infancy, there were few avenues for attack. With those avenues turned off, all else was allowed. Hence "default permit." Another area is code execution: anything clicked is permitted to run, unless stopped by antivirus or the likes. The proper solution here is default deny, but this, according to Ranum, takes dedication, thought, and understanding, and so is seldom done. And it allows one to sleep better at night.


2) Enumerating Badness


This is a subset of Default Permit, but is interesting as well. As mentioned previously, there were only a few avenues for attack, so if you blocked those vectors, you should be good, right? No, this is "enumerating badness." This is a dumb idea because of the incredible amount of badness that exists. Antivirus tries to track the thousands and thousands of viruses, etc and stop them, rather than a solution that tracks the (very few) legitimate applications that regularly run and deny all else. Why is this not a consumer solution in today's world?




Another great concept is that of ["Artificial Ignorance"](http://www.ranum.com/security/computer_security/papers/ai/index.html), where you get rid of uninteresting log entries, and keep all else, which, if they are not uninteresting, must be interesting.


3) Penetrate and Patch


In regards to one's online resource, you attack it as an attacker would, find a flaw, fix it, and continue searching. There is a brilliant term for this as Ranum says: "turd polishing." This process does nothing to make your code better in the long run, but management likes the improved, shiny appearance in the short term. It does not improve the design, rather "toughens by trial and error." This seems obvious when one thinks about it, but it is so prevalent that one hardly realizes how dumb it is. Vulnerability researchers publish holes, and holes are patched.




But if vendors wrote code "designed to be secure and reliable, then vulnerability discovery would be tedious." Think Internet Explorer: vulnerabilities have been found for over ten years. Ranum says pen-testing is pointless and pointless is dumb, because one will either find numerous bugs, or nothing comprehensible. Secure by design!


4) Hacking is Cool


Ranum say here that "hacking is a social problem." With internet anonymity, timid people can become criminals, and media portrays them as "whiz kids". Ultimately, teaching oneself exploits means investing time learning tools and techniques that become useless when everyone has patched that particular hole. Ones professional skill-set "becomes dependent on penetrate and patch" and you have arms race again.




While I see what Ranum is saying here, I believe knowing how these exploits work, and how holes are exploited is still useful to know. I do entirely agree with this statement, though: "it would be more sensible to design security systems that are hack-proof than to learn how to identify security systems that are dumb."


5) Educating Users


This is interesting as well, because it, too, seems so prevalent and accepted today. Education is good, right? If "educating users was going to work, it would have worked by now." People are easily socially engineered. Ranum likens it to penetrate and patch, and having to "patch" users every week. He asks "why do we need to educate users at all?" This is like Default Permit again - "Why are users getting executable attachments at all?" The root issue is not dumb users, but rather the security architecture that is broken.


6) Action is Better than Inaction


Here we have "early adopters" and "pause and thinkers." Ranum says "pause and thinkers" build more successful, secure, mission-critical systems. He illustrates this with "one senior IT executive's roll out plan for a wireless corporate network was 'wait two years and hire the guy who did a successful wireless deployment for a company larger than us.' The technology will be more mature and cheaper by then."


So: to myself or another reader who has stumbled along this far, I highly recommend (re)reading Ranums entire article. And maybe check out his website, which is full of interesting links. I think a takeaway here is to identify the root cause and fix that, rather than continue turd polishing everything in sight; that is surely a losing battle.
