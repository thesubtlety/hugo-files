---
title: "How to Use the Shodan API at Scale"
date: 2019-12-10T18:07:57-08:00
---

This is a quick post mostly for refreshing my memory in the future. I recently wanted to download the data Shodan had on a large corporate IP space with disparate ranges and several hundred thousand IP addresses for post processing.

As far as I can tell the Shodan help docs are scattered across too many pages and domains and subdomains. There are a few guides out there on the basics of Shodan CLI and API but I didn't see anything that documented things at a slightly larger scale so here are a few quick notes on gathering this data. Shodan needs no introduction, and the basics are well covered so I'll dive in.

### API Plans and Credits and Scanning Credits and Download Credits and Oh My

API plans? Credits? What do you need to know to make sure you have the right one? In my case I just wanted to download the data Shodan had and for the moment didn't need to make use of any scanning or real-time data feed features. The Freelancer plan would work in this case but fortunately for me, my employer is helping funding Shodan with a corporate license. This also gives me access to bulk lookups which speeds up time to results.

### Pricing
|[Data](https://developer.shodan.io/billing/signup)|Freelancer|Small Business|Corporate|Enterprise|
|------|------|------|------|------|
|Price|$59/month|$299/month|$899/month|$You don't want to ask|
|Results/month<br/> (query credits)|1MM<br/> (100 credits)|20MM<br> (2,000 credits)|Unlimited<br/>(100,000 credits)|Unlimited|
|IP scans/month<br/> (scan credits)|5,000|65,000|300,000|Unlimited|
|Results Downloads<br/> (export credits)|200,000<br/>(20 credits)|Unsure|1MM<br/>(100 credits)|Bulk Data Feed (all of it)|
|Filters|Most<br/> undefined)|Most<br/> (undefined)|All|All|
|Vulnerability Search Filter||Yes|Yes|Yes|
|Bulk IP Lookups|||Yes|Yes|
|Tag Search Filter|||Yes|Yes|

If you're not going past the first page and not using filters, no credits are being used and no account is required.

## Credit Types
Obtaining data costs you "credits". Depending how you access it you're using different credit types. The following info comes from the [Shodan Credits Explained](https://help.shodan.io/the-basics/credit-types-explained) page, which mostly just confuses me.

|Credit Type|Purpose|When they're used|
|-----|-------------|---------|
|Query| <ul><li>Searching via the API with filters</li><li>Searching via the website beyond page 2</li><li>100 results per query credit</li><li>Renewed monthly</li></ul>| Used by default with the website  <br/>and API|
|Scan|<ul><li>Request network scans</li><li>1 IP per scan credit</li><li>Renewed monthly</li></ul>|When you want results faster<br/> than Shodan's monthly internet scan ([On Demand Scanning](https://help.shodan.io/the-basics/credit-types-explained)).<br/> Used with the `scan()` API call or `scan submit` CLI command.|
|Export|<ul><li>Download search results from the website</li><li>10,000 results per credit</li><li>Single use, pricing per credit varis 2.50-5$/credit</li></ul>|If you need to download from the web. Note that every download <br/> request will use a credit, even if your <br/>search has 100 results. CSV format loses 90% of the data and you can't <br/> change the format once <br/>selected without using another <br/>credit - download the JSON.|

You can check your current usage at https://developer.shodan.io/dashboard

### CLI Usage
This is straightforward and the docs are at https://cli.shodan.io/ . The CLI can also be used to search and parse data.
```
$ shodan search -h
shodan search [OPTIONS] <search query>
$ shodan search --fields ip_str,port,org,hostnames microsoft iis 6.0

$ shodan download -h
shodan download [OPTIONS] <filename> <search query>
$ shodan download --limit 100 file_name filter:query

$ shodan parse -h
shodan parse [OPTIONS] <filenames>
$ shodan parse --fields ip_str,port,org --separator , microsoft-data.json.gz

$ shodan convert -h
shodan convert [OPTIONS] <input file> <output format>

$shodan convert file_name.json.gz csv
```
Keep in mind, this is all in Python so the CLI tools can be trivially modified - find where your shodan.py files are installed and modify as you please. For example, `shodan scan list` only returns the last 10 results, but if you go look at [the source](https://github.com/achillean/shodan-python/blob/166597f4a9756dc38ed2077d8df73340efaa8eb4/shodan/cli/scan.py#L36), you'll see you can quickly make changes to the REST calls (at `~/.local/lib/python3.6/site-packages/shodan/cli/scan.py` on my system).

### Downloading data with the API

There's a pretty basic API example in the [Shodan API Guide](https://help.shodan.io/guides/how-to-download-data-with-api#programming-with-the-shodan-api) to get you started. In my case I had thousands of IPs and ranges I was looking at and the `api.host()` [bulk lookup function](https://help.shodan.io/developer-fundamentals/looking-up-ip-info#bulk-lookups) was useful as it can take in array of 100 IPs per request. Note this feature requires a Corporate API plan.

```python
import shodan
api = shodan.Shodan('YOUR CORPORATE API KEY')

hosts = api.host([
    '8.8.8.8',
    '8.8.4.4',
])

for info in hosts:
    print(info['ip_str'])
```

Once data has been downloaded, you can use the CLI to parse, but additional processing with Python can be useful. There are a few built in helper functions outlined on the [Working with Shodan Data Files](https://help.shodan.io/mastery/working-with-shodan-data-files#custom-analysis) page. I ended up just writing my own, dumping the json in a format that still allowed the CLI to parse it.

The following scripts should help get you started with downloading data from Shodan, start scans, and parse out some CVEs from the downloaded data files.

**Download Shodan Data from a list of CIDRs or IPs**
{{< gist thesubtlety fb99a033981eb5091384de316507cca6 >}}

**Scan IPs from a file**
{{< gist thesubtlety 01bac27462b1168d6ef2a4787fb4eff4 >}}

**Parse out CVEs and save to CSV**
{{< gist thesubtlety f222bf5910e58785b9df2b22081c82c9 >}}

Of note: the banner specs if you're parsing this data can be useful for types and optional fields - https://developer.shodan.io/api/banner-specification. 

Also useful is the list of query filters (below), most of which can be used with `shodan parse --fields <filter>`.

## Using the Scanning API

Just a quick blurb on this. Again, this requires a paid API plan. From the docs
> Shodan crawls the entire Internet at least once a month, but if you want to request Shodan to scan a network immediately you can do so using the on-demand scanning capabilities of the API. A few common reasons to launch a scan are:
> * Validate firewall rules
> * Confirm issue was patched/ fixed
> * Check custom ports

And a note about scan status. Due to the way banner grabbing and services enumeration is done, a scan status might say `DONE` but the results won't actually be ready. `DONE` in this case means it's been picked up and has started to process. It's a known caveat and if you need results ASAP they can be picked up with [Shodan network monitor](https://help.shodan.io/guides/how-to-monitor-network) or simply waiting some period of time before downloading the results. Check out the [REST API docs](https://developer.shodan.io/api#shodan-scan-status) on scan statuses.

## Query Filters
From the [API docs](https://developer.shodan.io/api#shodan-host-search), a list of search query filters:

|Filter|Description|
|------|-----------|
|after|Only show results that were collected after the given date (dd/mm/yyyy).|
|asn|The Autonomous System Number that identifies the network the device is on.|
|before|Only show results that were collected before the given date (dd/mm/yyyy.|
|city|Show results that are located in the given city.|
|country|Show results that are located within the given country.|
|geo|There are 2 modes to the geo filter: radius and bounding box. To limit results based on a radius around a pair of latitude/ longitude, provide 3 parameters; ex: geo:50,50,100. If you want to find all results within a bounding box, supply the top left and bottom right coordinates for the region; ex: geo:10,10,50,50.|
|hash|Hash of the "data" property|
|has_ipv6|If "true" only show results that were discovered on IPv6.|
|has_screenshot|If "true" only show results that have a screenshot available.|
|hostname|Search for hosts that contain the given value in their hostname.|
|isp|Find devices based on the upstream owner of the IP netblock.|
|link|Find devices depending on their connection to the Internet.|
|net|Search by netblock using CIDR notation; ex: net:69.84.207.0/24|
|org|Find devices based on the owner of the IP netblock.|
|os|Filter results based on the operating system of the device.|
|port|Find devices based on the services/ ports that are publicly exposed on the Internet.|
|postal|Search by postal code.|
|product|Filter using the name of the software/ product; ex: product:Apache|
|state|Search for devices based on the state/ region they are located in.|
|version|Filter the results to include only products of the given version; ex: product:apache version:1.3.37|
|bitcoin.ip|Find Bitcoin servers that had the given IP in their list of peers.|
|bitcoin.ip_count|Find Bitcoin servers that return the given number of IPs in the list of peers.|
|bitcoin.port|Find Bitcoin servers that had IPs with the given port in their list of peers.|
|bitcoin.version|Filter results based on the Bitcoin protocol version.|
|http.component|Name of web technology used on the website|
|http.component_category|Category of web components used on the website|
|http.html|Search the HTML of the website for the given value.|
|http.html_hash|Hash of the website HTML|
|http.status|Response status code|
|http.title|Search the title of the website|
|ntp.ip|Find NTP servers that had the given IP in their monlist.|
|ntp.ip_count|Find NTP servers that return the given number of IPs in the initial monlist response.|
|ntp.more|Whether or not more IPs were available for the given NTP server.|
|ntp.port|Find NTP servers that had IPs with the given port in their monlist.|
|ssl|Search all SSL data|
|ssl.alpn|Application layer protocols such as HTTP/2 ("h2")|
|ssl.chain_count|Number of certificates in the chain|
|ssl.version|Possible values: SSLv2, SSLv3, TLSv1, TLSv1.1, TLSv1.2|
|ssl.cert.alg|Certificate algorithm|
|ssl.cert.expired|Whether the SSL certificate is expired or not; True/ False|
|ssl.cert.extension|Names of extensions in the certificate|
|ssl.cert.serial|Serial number as an integer or hexadecimal string|
|ssl.cert.pubkey.bits|Number of bits in the public key|
|ssl.cert.pubkey.type|Public key type|
|ssl.cipher.version|SSL version of the preferred cipher|
|ssl.cipher.bits|Number of bits in the preferred cipher|
|ssl.cipher.name|Name of the preferred cipher|
|telnet.option|Search all the options|
|telnet.do|The server requests the client to support these options|
|telnet.dont|The server requests the client to not support these options|
|telnet.will|The server supports these options|
|telnet.wont|The server doesnt support these options|

## References
* https://developer.shodan.io/api
* https://shodan.readthedocs.io/en/latest/index.html
* https://help.shodan.io/mastery/working-with-shodan-data-files
* https://help.shodan.io/developer-fundamentals/looking-up-ip-info
* https://github.com/achillean/shodan-python
* https://danielmiessler.com/study/shodan/
* https://pen-testing.sans.org/blog/2015/12/08/effective-shodan-searches


