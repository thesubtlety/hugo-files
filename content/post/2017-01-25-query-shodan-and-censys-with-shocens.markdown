+++
date = "2017-01-25T21:06:57-08:00"
title = "Search Shodan and Censys With Shocens"
draft = false
+++

Recon is close to [step one](http://www.pentest-standard.org/index.php/Intelligence_Gathering) in any pentest. When it comes to passively pulling data on infrastructure assets you have a number of options. [ARIN](https://whois.arin.net/ui/advanced.jsp) can help identify an organization's registered net blocks, but that's only part of the picture. With many organizations based in or using cloud services, those assets won't necessarily be registered to your target. 

And when AWS for example can tie [directly into a datacenter](https://aws.amazon.com/directconnect/), these servers become quite valuable. As an aside to AWS, check out [Gone in 60 Milliseconds](https://media.ccc.de/v/33c3-7865-gone_in_60_milliseconds) by [Rich Jones](https://github.com/Miserlou) - awesome talk. Now if a developer stands up a server with HTTPS using a corporate certificate it's likely going to be picked up and indexed by someone, Shodan, or Censys - so let's make use of that.


## Shocens

I'll cover Shodan and Censys in a bit more detail below, but suffice it to say I needed a tool that queried these search engines for specific organizations and let me do something useful with the data. Built in tools for Shodan are great for macro searches but I found myself wanting more when targeting a specific organization that had more than a few pages of data but didn't consist of hundreds of thousands of results. The Python APIs and CLI tools available just weren't quite what I was looking for.

This being my small motivation along with a desire to do some more Ruby development, I wrote **Shocens** - a little tool to

* make basic queries of both Shodan and Censys
* parse the results with options to diff against past scans
* and output to csv and txt

There is still a lot of potential to parse additional data from both search engines and cross query to fill in the blanks where one search engine has data while the other does not. It's less than perfect, and you'll obviously find the native search engines provide more power for complex queries. But it was fun to write, and still provides me a bit of value.

More details on Shocens usage are available on Github - https://github.com/thesubtlety/shocens

```
-> % ruby shocens.rb -q 'parsed.extensions="shodan"' -l 100
[+] Beginning Shodan search for org:google
[+] 687497 results in org:"google"
[+] Limiting results to 1 pages...

[+] Parsing page 1 of 1

Host:		104.131.0.69: ports 80
Server:		nginx/1.4.6 (Ubuntu)
Powered By:	
Title:		Shodan Internet Census
Cert Names:	
```

Following is a brief overview of both Shodan and Censys along with various useful search filters.

## Shodan

[Shodan]( https://www.shodan.io/) is "the world's first search engine for Internet-connected devices". There are quite a few resources out there on what Shodan is and how to use it so I won't go into great detail. The slogan sums it up quite well. If there is a device reachable on the internet and you know what to look for, Shodan will help you find it.

#### Search Filters

Where the real beauty of Shodan comes in is with filters

* `net:10425.89.0/24`
* `org:Microsoft`
* `title:tagged-scraped-content`
* `html:search-the-page`
* `product:banner-id`
* `version:v1.2.3` 
* `city:Seattle`
* `country:USA`
* `geo:12.3456,78.9087`
* `hostname:.edu`
* `os:AIX`
* `port:80`
* `before/after:01/01/1970`

Depending on what you're looking to accomplish a combination of `net`, `html`, and `org` have served me well for targeted recon. See the [banner-specs](https://developer.shodan.io/api/banner-specification) for more possible filters. And John Matherly himself wrote the [Complete Guide to Shodan](https://leanpub.com/shodan) starting at one dollar which is probably worth checking out.

#### APIs and Credits

It's worth noting you'll need an account to do anything useful with Shodan (beyond a simple query with one page of results). Using filters, seeing results beyond one page, and using the API requires a paid account. It's only around ~$45USD, there are frequent deals on paid membership for full API access, maybe free for .edu, and totally worth it. This will give you around 10,000 results per month. Register [here](https://account.shodan.io/register).

#### Resources

* [Effective Shodan Searches](https://pen-testing.sans.org/blog/2015/12/08/effective-shodan-searches/)
* [A Shodan Tutorial](https://danielmiessler.com/study/shodan/)
* [Searching Shodan for Fun and Profit](https://www.exploit-db.com/docs/33859.pdf)

## Censys
 
[Censys.io](https://censys.io/) is "a search engine that allows computer scientists to ask questions about the devices and networks that compose the Internet". Same thing as Shodan - it lets you identify what's out there. They pull data daily and use Zmap to get their [data](https://scans.io/).

#### Search Filters

* Supports everything Shodan does and then some

Actually, just go check out their website. The documentation is quite good. The [Overview page](https://censys.io/overview), Examples tab has basic query examples, but you can really filter on just about anything. The following page covers a few: https://www.censys.io/ipv4/72.14.246.220/table

Again, depending on what you're looking for, I've had good luck using CIDR blocks: `127.0.0.1/24`, parsing
certificates: `parsed.extensions=domain.tld`, and ASes: `autonomous_system:description: 'Org Name'`.

#### APIs and Rate Limits

Again, you'll need an account. Censys usage is free, though and you can register [here](https://censys.io/register). You aren't limited by specific searches per month per se as with Shodan, but rather you get a limited number of requests per five minute bucket.

#### Resources

* [About Censys](https://censys.io/about)
* [A Search Engine Backed by Internet-Wide Scanning](https://jhalderm.com/pub/papers/censys-ccs15.pdf)

Thanks for reading and happy searching!
