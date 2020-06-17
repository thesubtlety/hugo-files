---
title: "Go Decrypt Jenkins"
date: 2020-06-16T18:59:49-07:00
---

Over the past few years I've run into vulnerable Jenkins backups with anywhere from half a dozen to several hundred encrypted passwords, secrets, and keys to critical infrastructure. While there are a multitude of tools out there none of them behaved quite like I wanted, so I wrote my own and learned some Golang in the process.

The tool isn't groundbreaking but it does do something I haven't seen available else where, and that is the ability to decrypt files encrypted with Jenkins'  `SecretBytes` implementation offline - not using the Groovy console. 

Go-Decrypt-Jenkins is on Github - https://github.com/thesubtlety/go-decrypt-jenkins.

### master.key encrypts hudson.util.Secret
Back in 2014 someone did some code spelunking and reverse engineering and [documented](https://web.archive.org/web/20190916195518/http://xn--thibaud-dya.fr/jenkins_credentials.html) how Jenkins credentials were being encrypted along with a decryption script. That script is still being used today. 

Basically, Jenkins has a `master.key` file which it uses to encrypt an secondary key. The secondary key is used to encrypt secret values. In the case of most Jenkins encrypted values, the secondary `hudson.util.Secret` key is used for encryption.

### ...and also encrypts SecretBytes.KEY
But in the case of files uploaded to the Credentials Manager in Jenkins, a different algorithm and secret key are used. The `master.key` is still used but the secondary key it encrypts is `com.cloudbees.plugins.credentials.SecretBytes.KEY` which is then used for file encryption.

Files encrypted with `SecretBytes` are tagged as such in `credentials.xml`. Searching Github shows the algorithms used for encryption and decryption in [SecretBytes.java](https://github.com/jenkinsci/credentials-plugin/blob/master/src/main/java/com/cloudbees/plugins/credentials/SecretBytes.java#L95-L121).

That `SecretBytes` implementation uses `CredentialsConfidentialKey` to create the cipher data as seen in the `createCipher` implementation [here](https://github.com/jenkinsci/credentials-plugin/blob/master/src/main/java/com/cloudbees/plugins/credentials/CredentialsConfidentialKey.java#L150). 

### Decrypt all the things
And after working to understand how those algorithms worked, I rewrote them in Go.

Prior to this the easiest way to decrypt files encrypted with `SecretBytes` was to use the Groovy Console and run something like 

```java
println(new String(com.cloudbees.plugins.credentials.SecretBytes.fromString("{....}").getPlainData(), "ASCII"))
``` 

Now this can be done offline. Just point at a directory and go-decrypt-jenkins will do the rest.

{{< highlight golang >}}
% ./go-decrypt-jenkins -d jenkinsbackup/
scope: GLOBAL
id: 42e60ee3-fe19-4e3e-9eec-fec91e96e92e
username: jenkin
privateKey: -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAx5T0czKNmNkA7k0mbBJkl8hTLAzy...

scope: GLOBAL
id: al2e8dee-afe1-e3be-b5e1-7e797e9a9ede
username: admin
password: Password123
{{< /highlight >}}

https://github.com/thesubtlety/go-decrypt-jenkins