---
author: noah
comments: false
date: 2015-08-23 00:27:58+00:00
layout: post
slug: opendnss-appsec-training-lab
title: OpenDNS's AppSec Training Lab
wordpress_id: 228
categories:
- Development
- Miscellany
tags:
- opendns
- owasp
- training
---

I came across OpenDNS Security Ninjas AppSec [Training Lab](https://github.com/opendns/Security_Ninjas_AppSec_Training) not too long ago and found its simplicity rather enjoyable. It's a simple web app written in PHP which illustrates each of the [OWASP Top 10](https://www.owasp.org/index.php/Top_10_2013-Table_of_Contents) categories. As I was going through the exercises I found myself checking to see how the vulnerable code was written and how the issues could be remediated.

Since the lab is geared towards beginners, I thought it might be helpful to provide brief explanations along with links to the relevant lines of source code. For each level/OWASP vulnerability, I simply added a "Why" section to each "Solution" area linking to the sink on Github along with a brief explanation.

The merge request is apparently pending an OpenDNS maintainer, but the fork is on [Github](https://github.com/thesubtlety/Security_Ninjas_AppSec_Training).

