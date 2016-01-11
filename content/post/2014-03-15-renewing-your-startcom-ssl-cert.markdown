---
author: noah
comments: false
date: 2014-03-15 00:57:49+00:00
layout: post
slug: renewing-your-startcom-ssl-cert
title: Renewing your StartCom SSL Cert
wordpress_id: 141
categories:
- Miscellany
---

Since I've forgotten how to do this over the past year, here are the directions for posterity.

1. Startcom sends you a reminder after 50 weeks and opens a window for a renewal. Log in and validate your email and domain using the Validation Wizard. Note, you need to ensure your email is going to forward properly.

2. Generate a key and CSR on the server with the following two commands
`openssl genrsa -out ./www.thesubtlety.com.key 2048` 
`openssl req -new -key www.thesubtlety.com.key -out www.thesubtlety.com.csr`

3. Once your domain is validated by StartSSL, you need to request a new certificate which is pretty self explanatory. Use the Certificate Wizard, follow the prompts, and paste in the CSR where asked.

4. Once you've got that, copy it to a .crt file on the server.

5. Don't forget the chain file. This can be created by cat-ing the files ca.pem and sub.class1.server.ca.pem [here](https://www.startssl.com/certs/ ) into a .chn file.

The NFS SSL help and request link is here: https://members.nearlyfreespeech.net/username/support/assist?tag=ssl

And finally, verify the newly installed cert is updated with a new expiration date.
