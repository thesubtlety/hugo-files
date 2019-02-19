+++
date = "2019-02-16T16:32:17-08:00"
draft = false
title = "Monkeying Around: Patching the boto3 User-Agent"

+++

I was recently doing some testing in AWS with some "obtained" access keys. Part of this engagement was to identify some threshold at which the blue team was noticing and engaging with suspicious activity and as such we were running some automated tooling. In AWS this can mean bruteforcing services and creating quite a bit of logs. 

After not so long we got a request asking if we were up to anything - success! Blue had noticed something was up! But to be honest, I hadn't expected them to be on to us so quickly. And when we debriefed we discovered Amazon GuardDuty had alerted that someone was making requests from Kali ([`PenTest:IAMUser/KaliLinux`](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_pentest.html)). This feature was released late December, 2018. Now how did GuardDuty know this? Their documentation states the following.

>This finding informs you that a machine running Kali Linux is making API calls using credentials that belong to your AWS account. Your credentials might be compromised. Kali Linux is a popular penetration testing tool that security professionals use to identify weaknesses in EC2 instances that require patching. Attackers also use this tool to find EC2 configuration weaknesses and gain unauthorized access to your AWS environment. For more information, see Remediating Compromised AWS Credentials.

If you look at your traffic running any AWS tools which use the `boto3` library you'll see the issue pretty quickly.

{{< highlight text "hl_lines=8" >}}
POST https://sts.amazonaws.com/ HTTP/1.1
Host: sts.amazonaws.com
Accept-Encoding: identity
Content-Length: 43
Content-Type: application/x-www-form-urlencoded; charset=utf-8
Authorization: AWS4-HMAC-SHA256 Credential=AKIAICFBINBSWOTRB123/20190207/us-east-1/sts/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=123ab1c26b2850431123abcd33d28051f8ab12303as32a23d44ab123ac313a42a
X-Amz-Date: 20190207T203132Z
User-Agent: Boto3/1.7.29 Python/2.7.6 Linux/4.14.0-kali3-amd64 Botocore/1.10.29

Action=GetCallerIdentity&Version=2011-06-15
{{< / highlight >}}

That looks like a Linux kernel version and release. The keyword `kali` is included in the release and so it gets added to the User Agent itself which could be how Amazon thinks this is suspicious. How? After some digging with `pdb.set_trace()` I found the relevant bit of code which you can view on [Github](https://github.com/boto/botocore/blob/develop/botocore/session.py#L451).
{{< highlight python >}}
# botocore/session.py
def user_agent(self):
    base = '%s/%s Python/%s %s/%s' % (self.user_agent_name,
		self.user_agent_version,
		platform.python_version(),
		platform.system(),
		platform.release())
	return base
{{< / highlight >}}

Fire up python and you can confirm what you're seeing in the User Agent. Also, `aws --version` will probably give you the same info.
{{< highlight python >}}
>>> import sys, platform
>>> platform.python_version()
'2.7.6'
>>> platform.system()
'Linux'
>>> platform.release()
'4.14.0-kali3-amd64'
{{< / highlight >}}

Of course I want the option of continuing to use AWS tools on Kali without disclosing the fact. As far as I can tell, `platform` is calling `uname`. This is a syscall in Linux (so changing `/bin/uname` won't do any good) and while there may be a way around it with `LD_PRELOAD`, my (lack of) skills and lack of desire to spoof whatever struct was being expected, I decided to see what could be done with Python.

#### Patching
After identifying the `session.py` file imported with the `boto3` libary, and setting `pdb.set_trace()` in the relevant `user_agent` functions I found the file I was looking for when `import botocore.session` was called. Yours will differ but mine was living at `/usr/local/lib/python2.7/dist-packages/botocore-1.12.89-py2.7.egg/botocore/session.py`. 

In a naiive test, I simply overwrote the user agent info in `base` right before the return.
{{< highlight python >}}
base = '%s/%s Python/%s %s/%s' % (self.user_agent_name,
	self.user_agent_version,
	platform.python_version(),
	platform.system(),
	platform.release())
if os.environ.get('AWS_EXECUTION_ENV') is not None:
	base += ' exec-env/%s' % os.environ.get('AWS_EXECUTION_ENV')
if self.user_agent_extra:
	base += ' %s' % self.user_agent_extra
base = "Boto3/1.9.89 Python/2.7.12 Linux/4.1.2-34-generic"
return base
{{< / highlight >}}

And sure enough, after restarting the interpreter and configuring a client session, my spoofed user agent was used.

{{< highlight python >}}
s = boto3.Session(profile_name="test")
c = s.client('sts', verify=False)  # user agent spoofed here
{{< / highlight >}}

If you want to hardcode this for work in the REPL or any tools using your installed `boto3` library, you can patch the source simply enough. Below might work but it's a hack, so maybe do it manually.
{{< highlight bash >}}
# This probably won't work for you. Don't do this.
# Find where your botocore sessions.py file is living and patch
F=$(python -v -c "import boto3" 2>&1 > /dev/null| grep -i 'botocore/session.py$' 2>/dev/null | cut -d' ' -f4)
sed -i 's/        return base/        base = "Boto3\/1.9.89 Python\/2.7.12 Linux\/4.2.0-42-generic"\n        return base/' $F
{{< / highlight >}}

#### Monkey Patching

So now we know how to spoof this manually, how can we override this automatically? I don't know much about Python, but I do know you can overwrite a method, and Stack Overflow lets any fool (yours truly) cobble things together (that shouldn't be cobbled, really). First I tried to override the imported Session class method with a custom function, but that seemed to break my client call. I found that using the `monkeypatch` module of the `pytest` library let me correctly overwrite the function and things continued to work. I'm sure this can be done without a library, but this seems to work nicely.

First we install `pytest` and then in the following snippet we import `monkeypatch`, create our custom `my_user_agent` function, and patch the original `user_agent` with our custom one.
{{< highlight python >}}
from _pytest.monkeypatch import MonkeyPatch
monkeypatch = MonkeyPatch()
def my_user_agent(self):
	return "Boto3/1.9.89 Python/2.7.12 Linux/4.2.0-42-generic"

monkeypatch.setattr(botocore.session.Session, 'user_agent', my_user_agent)
{{< / highlight >}}

And now when we run configure a `boto3` client session, things will work as expected without having to patch the source code itself.

So if we are running [Pacu](https://github.com/RhinoSecurityLabs/pacu) for example, a really cool tool for all things AWS penetration testing and we want to do the above, it ends up being pretty simple. Within [pacu.py](https://github.com/RhinoSecurityLabs/pacu/blob/master/pacu.py) in the first try/except block where things are being imported, we simply add the following (directly before the `except`).

{{< highlight python "linenos=table,linenostart=31" >}}
from _pytest.monkeypatch import MonkeyPatch

monkeypatch = MonkeyPatch()
def my_user_agent(self):
	return "Boto3/1.9.89 Python/2.7.12
	        Linux/4.2.0-42-generic"

monkeypatch.setattr(botocore.session.Session, 'user_agent', my_user_agent)

{{< / highlight >}}
Now when you run Pacu, you'll have spoofed your user agent as we can see in the following screenshot.

![spoof](/img/boto3-request-pacu.jpg)

If you want to add debugging, follow these [Stack Overflow directions](https://stackoverflow.com/questions/10588644/how-can-i-see-the-entire-http-request-thats-being-sent-by-my-python-application) and add that code directly following the above monkey patch. 

Of course, they're packaging `botocore` in the repo so you could simply patch the correct file again, but where's the fun in that? It's worth noting Pacu has some User Agent spoofing functionality in the [PacuProxy feature](https://github.com/RhinoSecurityLabs/pacu/wiki/Advanced-Capabilities) (which I haven't yet used) and may be worthy of further reading.

So there we go - a quick few lines are all that is needed to use AWS libraries on Kali without triggering GuardDuty `PenTest:IAMUser/KaliLinux` alerts. Disclaimer: Probably. Only very brief testing of this theory performed. YMMV. Recommended reading: [Amazon GuardDuty Findings](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_trojan.html).

We always say "know your tools" and "test before you execute", and while we might have a good idea of what's happening under the hood and have done basic testing we commonly make assumptions about how things are working or miss a new defense that is released; just like in this case. Lesson learned.

Thanks for reading!

### Post Script
A more complete example with logging so you can verify everything is working as expected. Good for copy paste in the interpreter.

{{<gist thesubtlety 495c08cc37b799b1f5451cce9d255c91>}}


