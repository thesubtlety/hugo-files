---
title: "Brute Forcing 389-ds PBKDF2 Passwords"
date: 2019-09-23T20:52:14-07:00
draft: false
---

Several times now I've run across password hashes created by [389-ds](https://directory.fedoraproject.org/), RedHat's open source LDAP Directory Server solution. During a red team past operation I discovered a backup [LDIF file](https://en.wikipedia.org/wiki/LDAP_Data_Interchange_Format) which included hashed user passwords (think NTDS.dit but not as catastrophic). A number of the hashes were in prepended with `PBKDF2_SHA256`.

While hashcat and john the ripper have support for most algorithms, they are at the moment lacking support for 389-ds's `PBKDF2_SHA256` implementation. And as far as I can tell, nothing currently exists to easily verify or check passwords against these hashes. Base64 decoding the hashes I discovered didn't immediately point to quick solutions either. But 389-ds is open source, so when you need to crack passwords, the source is good place to turn.

The rest of this post walks through my journey reimplementing the algorithm and writing some utilities to help brute force these password hashes in Python. If you're just looking for the source to try this out, check out the [Github repo](https://github.com/thesubtlety/389-ds-password-check).

# A quick primer on LDAP and 389-ds
To get started understanding how these hashes were being created, I stood up my own instance of 389-ds on CentOS. There are a [few](https://directory.fedoraproject.org/docs/389ds/howto/quickstart.html) good [guides](https://www.thegeekstuff.com/2017/07/ldap-389-directory-server-install/) on getting things set up so I won't go into detail on that.

Only the server is necessary and the default common configurations are fine for our needs. I needed a few test users and those can be added with standard [ldif files](https://www.digitalocean.com/community/tutorials/how-to-use-ldif-files-to-make-changes-to-an-openldap-system) or the `ldapmodify` utility. In addition, I needed to change the password storage scheme to `PBKDF2_SHA256` rather than the default salted SHA or `SSHA512`. I found ldif to be fairly finicky if spaces or tabs were in unexpected places so if you're running into issues [ldapvi](https://www.chriscantwell.co.uk/2009/11/using-ldapvi-to-quickly-modify-ldap-directories/) worked for me as well.

{{< highlight txt >}}
## 389 DS, defaults to SSHA512, change 
-># ldapmodify -D "cn=Directory Manager" -W -x
dn: cn=config
changetype: modify
replace: passwordStorageScheme
passwordStorageScheme: PBDKF_SHA256
^D

## Add a user, note passwords must be submitted in ldpamodify/ldapadd in cleartext
-># ldapmodify -D "cn=Directory Manager" -W -x
dn: cn=username1,ou=People,dc=examplevictim,dc=com
changeType: add
sn: username1
cn: username1
objectClass: inetOrgPerson
userPassword: Password123
{{< / highlight >}}

There's a ton a person could go into around LDAP, ldif, and the various configurations and policies, but I'll gloss over those for now. When you setup 389-ds initially you create a Directory Manager user with full access to make changes to the LDAP environment and configuration. This is synonymous with Domain Admin but only applies to the Directory itself (it isn't used to access other resources for example). Typically it is the only user with access to view the userPassword field which contains hashed user passwords. Keep in mind it is possible to have passwords simply encoded in Base64 or passwords hashed using weaker algorithms dependingon how things have been configured and migrated. To grab all the objects and properties, the following command can be used.

`ldapsearch -x -b "dc=examplevictim,dc=com" -D "uid=admin,ou=Administrators,ou=TopologyManagement,o=NetscapeRoot" -W`

{{< highlight txt >}}
# extended LDIF
#
# LDAPv3
# base (dc=examplevictim,dc=com) with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#
# username1, People, examplevictim.com
dn: cn=username1,ou=People,dc=examplevictim,dc=com
sn: username1
cn: username1
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
objectClass: top
userPassword:: e1BCS0RGMl9TSEEyNTZ9QUFBbkVHVHhYdG5SL29veDkyMi9qWnlqSDZmbWlJZFc
 0QXdJWVpFMkxmQ1ZML1NVejVHYkFIZmpSajROYk4ydTh1bDAvai9kVXpKNGdRU2F3R0FMR0haVjc0
 bk9BdFB0dG9aRFRzaDdCZUdDTEQvUHM3dlJ1Z3dEZHo5dVBBUlh6RjNiRC84cUNwdW12UkdiNHBla
 HpmUXNrK0ZuR2dUd2kwclVlVmFOOGE3S2J2OFpwUmZVMnNkKzIwOEYvWUw0MkJXQWgvMnR2MEk0dl
 k3WnNyQ1pjclVKdGdLV3k1TnIrdDc4em1Qa3Jac1gva2dmbkdkWGhyNTBrTjEwY21rTFEwL2NaT1h
 vOUNBa3BlWnlGdSt3UTV2UWRVYUVTMlZkNWtCakpZUENrcjRiMm9jcjRFVFFpM0lHTzJHR0NvQ2V0
 bU1JRVRzdWRSVlN4VU5CYnZhK1ZneGluNUFwdTR3SVAvMFp5dUdLNlR1V0xxTG5OcG1LM1JrUngwe
 GpxSjRuTjJPazB1bDBYWUJKY1lJQnQ0VW9hVk0ydVNhL0V0dzI4VXkrekFzVXYyQU9pUm81
{{< / highlight >}}

There's that userPassword attribute. Note that many attributes are simply stored in Base64 as this one is. I wrote a utility to parse an ldif dump or the output from a privileged ldapsearch output file to grab all the user and userPassword fields and base64 decode them, available [here](TODO). Decoded that looks like

{{< highlight txt >}}
username1:{PBKDF2_SHA256}AAAnEGTxXtnR/oox922/jZyjH6fmiIdW4AwIYZE2LfCVL/SUz5GbAHfjRj4NbN2u8ul0/j/dUzJ4gQSawGALGHZV74nOAtPttoZDTsh7BeGCLD/Ps7vRugwDdz9uPARXzF3bD/8qCpumvRGb4pehzfQsk+FnGgTwi0rUeVaN8a7Kbv8ZpRfU2sd+208F/YL42BWAh/2tv0I4vY7ZsrCZcrUJtgKWy5Nr+t78zmPkrZsX/kgfnGdXhr50kN10cmkLQ0/cZOXo9CAkpeZyFu+wQ5vQdUaES2Vd5kBjJYPCkr4b2ocr4ETQi3IGO2GGCoCetmMIETsudRVSxUNBbva+Vgxin5Apu4wIP/0ZyuGK6TuWLqLnNpmK3RkRx0xjqJ4nN2Ok0ul0XYBJcYIBt4UoaVM2uSa/Etw28Uy+zAsUv2AOiRo5
{{< / highlight >}}

# And now an uninformed look at PBKDF2

There are a few terms to keep in mind with [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2) which can help in understanding what was going on with the implementation of this algorithm. PBKDF2 is a term that gets tossed around quite a bit in password hashing conversations and stands for "Password Based Key Derivation Function 2". A simple overview at [crypto-it](http://www.crypto-it.net/eng/theory/pbe.html) outlines it well. In essence, a user password, a random salt value (to prevent the same password from having the same hash), and an iteration count are fed into the algorithm to create an output hash. The only way to verify you have the correct password is running the password, salt, and iterations through the algorithm again and comparing the output.

That's well and good but there's another piece of the puzzle, and that is [PKCS#11](http://www.pkiglobe.org/pkcs11_terminology.html). I honestly haven't spent any on time understanding this beast but there are a few terms that show up in the source code that are helpful to know exist. There are "slots" which "are the logical partitions in the cryptographic device" which is clear as mud. A decent explanation can be found [here](https://linuxbsdos.com/2010/10/06/how-to-manage-disk-encryption-passphrases-and-key-slots/). And there are "mechanisms" which refer to the combination of cipher, hash function, and block mode. The Python [PKCS#11 docs](https://python-pkcs11.readthedocs.io/en/latest/applied.html) go into more detail on this. And with that background poorly covered let's go back to the interesting bits.

# Back to the source
Initially googling led me to the 389-ds-base source code and the [pbkdf2_pwd](https://pagure.io/389-ds-base/blob/542287c/f/ldap/servers/plugins/pwdstorage/pbkdf2_pwd.c) file. I grabbed the source from https://pagure.io/389-ds-base.git with a git clone. Releases are also available at  http://snapshot.debian.org/package/389-ds-base/. 

Not having used C since a freshmen in college, this looked rather intimidating at first. But after reading through several times and looking through the source code in VS Code several times with its helpful Go To Definition  Declaration features, things began to make sense.

![](/img/vscode-389.JPG)

The first thing to understand is how passwords are actually being hashed. Everything takes place in the `ldap/servers/plugins/pwdstorage/pbkdf2_pwd.c` file. The `pbkdf2_sha256_pw_enc_rounds` function sets things up. It creates an array with sufficient length to hold the output hash which will eventually contain the number of iterations, the salt, and the pbkdf2 hash. 

One key that threw me off was the [htonl](https://linux.die.net/man/3/htonl) function that takes place on the number of iterations. The iterations are stored in network byte order.

{{< highlight c >}}

//(PBKDF2_ITERATIONS_LENGTH[4] + PBKDF2_SALT_LENGTH[64] + PBKDF2_HASH_LENGTH[256]) == 324
char hash[PBKDF2_TOTAL_LENGTH]; 
size_t encsize = 3 + schemeNameLength + LDIF_BASE64_LEN(PBKDF2_TOTAL_LENGTH);
char *enc = slapi_ch_calloc(encsize, sizeof(char));

SECItem saltItem;
SECItem passItem;
char salt[PBKDF2_SALT_LENGTH]; //64 bytes

memset(hash, 0, PBKDF2_TOTAL_LENGTH);
memset(salt, 0, PBKDF2_SALT_LENGTH);
saltItem.data = (unsigned char *)salt;
saltItem.len = PBKDF2_SALT_LENGTH;
passItem.data = (unsigned char *)pwd;
passItem.len = strlen(pwd);

// create a random 64 byte salt value
slapi_rand_array(salt, PBKDF2_SALT_LENGTH);

//network byte order iterations
iterations = htonl(iterations);

{{< / highlight >}}

With this information, the `pbkdf2_sha256_hash` function is called to actually run the PBKDF2 algorithm and return the hash. This function takes in the iteration count, the salt, and user password to create a hash. You can see references to the PKCS#11 modules being called in `PK11_CreatePBEV2AlgorithmID`.

{{< highlight c >}}
// takes in hash out array, the length, the user password, salt, and iterations
pbkdf2_sha256_hash(char *hash_out, size_t hash_out_len, SECItem *pwd, SECItem *salt, uint32_t iterations)
{
    SECItem *result = NULL;
    SECAlgorithmID *algid = NULL;
    PK11SlotInfo *slot = NULL;
    PK11SymKey *symkey = NULL;

    algid = PK11_CreatePBEV2AlgorithmID(SEC_OID_PKCS5_PBKDF2, SEC_OID_HMAC_SHA256, SEC_OID_HMAC_SHA256, hash_out_len, iterations, salt);

    if (algid != NULL) {
        slot = PK11_GetBestSlotMultiple(mechanism_array, 2, NULL);
        if (slot != NULL) {
            symkey = PK11_PBEKeyGen(slot, algid, pwd, PR_FALSE, NULL);
            PK11_FreeSlot(slot);
        }
    }
    if (PK11_ExtractKeyValue(symkey) == SECSuccess) {
        result = PK11_GetKeyData(symkey);
        if (result != NULL && result->len <= hash_out_len) {
            memcpy(hash_out, result->data, result->len);
            PK11_FreeSymKey(symkey);
        }
    }
    return SECSuccess;
{{< / highlight >}}

When the `pbkdf2_sha256_hash` function completes, the output hash array is populated and will contain:

`4 bytes of iteration count|64 bytes of salt|256 bytes of pbkdf2 key hash`

This array is then Base64 encoded and prepended with `{PBKDF2_SHA256}`. The final output looks like this:
```
{PBKDF2_SHA256}AAAnEGTxXtnR/oox922/jZyjH6fmiIdW4AwIYZE2LfCVL/SUz5GbAHfjRj4NbN2u8ul0/j/dUzJ4gQSawGALGHZV74nOAtPttoZDTsh7BeGCLD/Ps7vRugwDdz9uPARXzF3bD/8qCpumvRGb4pehzfQsk+FnGgTwi0rUeVaN8a7Kbv8ZpRfU2sd+208F/YL42BWAh/2tv0I4vY7ZsrCZcrUJtgKWy5Nr+t78zmPkrZsX/kgfnGdXhr50kN10cmkLQ0/cZOXo9CAkpeZyFu+wQ5vQdUaES2Vd5kBjJYPCkr4b2ocr4ETQi3IGO2GGCoCetmMIETsudRVSxUNBbva+Vgxin5Apu4wIP/0ZyuGK6TuWLqLnNpmK3RkRx0xjqJ4nN2Ok0ul0XYBJcYIBt4UoaVM2uSa/Etw28Uy+zAsUv2AOiRo5
```

The password compare function does much the same work. It extracts the relevant values, plugs them into the hashing algorithm, and compares the output to the existing key value. 

{{< highlight c >}}
pbkdf2_sha256_pw_cmp(const char *userpwd, const char *dbpwd)
{
    int32_t result = 1; /* Default to fail. */
    char dbhash[PBKDF2_TOTAL_LENGTH] = {0};
    char userhash[PBKDF2_HASH_LENGTH] = {0};
    int32_t dbpwd_len = strlen(dbpwd);
    SECItem saltItem;
    SECItem passItem;
    uint32_t iterations = 0;

    passItem.data = (unsigned char *)userpwd;
    passItem.len = strlen(userpwd);

    /* Decode the DBpwd to bytes from b64 */
    if (PL_Base64Decode(dbpwd, dbpwd_len, dbhash) == NULL) {
        slapi_log_err(SLAPI_LOG_ERR, (char *)schemeName, "Unable to base64 decode dbpwd value\n");
        return result;
    }
    /* extract the fields */
    pbkdf2_sha256_extract(dbhash, &saltItem, &iterations);

    /* Now send the userpw to the hash function, with the salt + iter. */
    if (pbkdf2_sha256_hash(userhash, PBKDF2_HASH_LENGTH, &passItem, &saltItem, iterations) != SECSuccess) {
        slapi_log_err(SLAPI_LOG_ERR, (char *)schemeName, "Unable to hash userpwd value\n");
        return result;
    }

    /* Our hash value is always at a known offset in the decoded string. */
    char *hash = dbhash + PBKDF2_ITERATIONS_LENGTH + PBKDF2_SALT_LENGTH;

    /* Now compare the result of pbkdf2_sha256_hash. */
    result = memcmp(userhash, hash, PBKDF2_HASH_LENGTH);

    return result;
}
{{< / highlight >}}

The `pbkdf2_sha256_pw_cmp` first base64 decodes the hash value, then extracts the first four bytes of iterations and performs a `ntohl`, followed by the next 64 bytes of salt, and then sends this info to the `pbkdf2_sha256_hash` function. As seen previously this function takes in the iterations, the salt, and given user password and returns a hash value. The stored hash value is compared to the newly created hash value; if they match, the correct password was given, and vice versa.


# What is NSS?
There are a few references to "NSS" in that source file, but it took me a little while to realize - [NSS](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/Overview) is a standard library used all over the place. It "provides a complete open-source implementation of the crypto libraries used by AOL, Red Hat, Google" and "is a set of libraries designed to support cross-platform development of security-enabled client and server applications" per the [Mozilla docs](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS). Used in Mozilla products, LibreOffice, _Red Hat Directory Server_, and even Oracle products. If you've ever used `certutil` or `modutil`, you've interacted with NSS.

Digging into this a bit more and doing some googling I discovered the [python-nss module](https://pypi.org/project/python-nss/) which implements the same functions described in the 389-ds PBKDF2 implementation. Jackpot!


# Tying it all together
With the python-nss library I discovered an [example pbkdf2](https://github.com/tiran/python-nss/blob/master/doc/examples/pbkdf2_example.py) implementation which allowed me to nearly plug and play the 389-ds PBKDF2 C implementation with a Python PBKDF2 implementation. Since there was at least one function that wasn't implemented in the python-nss module (e.g. `PK11_GetBestSlotMultiple`) the [source](https://pypi.org/project/python-nss/#files) of the python-nss helped ensure I was on the right direction as I re implemented things in Python (although the heavy lifting had all been taken care of in the example). For the most part, walking through the above password hashing and comparison functions and verifying where those occured in the PBKDF2 example led to a working algorithm with just a bit of trial an error. 

If you'll remember, iterations in the 389-ds implementation were run through `htonl`. This threw me for a loop not having encountered it in this manner before. The iteration bytes returned after base64 decoding a valid hash would look like `\x00\x00'\x10` but after playing around with various packing and unpacking methods in python I came across one that corresponded to the correct implementation. Generating the expected iteration bytes required packing as an unsigned int.

So `struct.pack("I", socket.htonl(10000))` becomes `\x00\x00'\x10` and vice versa, `int(socket.htonl(struct.unpack("I",'\x00\x00'\x10')[0]))` becomes `10000`.

# And finally
After being able to generate a PBKDF2 key with help from the python-nss example, it was relatively quick work to add functionality to compare a password hash to a given password. Now you can take a 389-ds `PBKDF2_SHA256` password hash and verify whether a given password is valid for that hash.

{{< highlight txt >}}
~/projects/389-testing/389ds-password-checker$ python3 389ds-pwdcheck.py -p Password123 --hash {PBKDF2_SHA256}AAAnEGTxXtnR
/oox922/jZyjH6fmiIdW4AwIYZE2LfCVL/SUz5GbAHfjRj4NbN2u8ul0/j/dUzJ4gQSawGALGHZV74nOAtPttoZDTsh7BeGCLD/Ps7vRugwDdz9uPARXzF3bD/8qCpumvRGb4pehzfQsk+FnGgT
wi0rUeVaN8a7Kbv8ZpRfU2sd+208F/YL42BWAh/2tv0I4vY7ZsrCZcrUJtgKWy5Nr+t78zmPkrZsX/kgfnGdXhr50kN10cmkLQ0/cZOXo9CAkpeZyFu+wQ5vQdUaES2Vd5kBjJYPCkr4b2ocr4E
TQi3IGO2GGCoCetmMIETsudRVSxUNBbva+Vgxin5Apu4wIP/0ZyuGK6TuWLqLnNpmK3RkRx0xjqJ4nN2Ok0ul0XYBJcYIBt4UoaVM2uSa/Etw28Uy+zAsUv2AOiRo5

Correct password: Password123
{{< / highlight >}}

I also ended up writing a few utilities to help you if you obtain an LDIF file with userPassword hashes. `ldif-to-hashes.py` takes a backup ldif file (or output from `ldapsearch` if it contains `userPassword` fields) and outputs them in `username:passwordhash` format. 

And `389ds-pwdcheck-harness.py` takes a list of usernames and hashes (e.g. from `ldif-to-hashes.py`) and a dictionary file and tries to crack the list of user hashes. It's multi-threaded but quickly written and as far as password crackers go, very inefficient. That said, it did net me valid passwords in short order! 

So given a backup ldif file or the results from ldapsearch e.g:
{{< highlight txt >}}
dn: cn=username1,ou=People,dc=examplevictim,dc=com
sn: username1
cn: username1
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
objectClass: top
userPassword:: e1BCS0RGMl9TSEEyNTZ9QUFBbkVHVHhYdG5SL29veDkyMi9qWnlqSDZmbWlJZFc
 0QXdJWVpFMkxmQ1ZML1NVejVHYkFIZmpSajROYk4ydTh1bDAvai9kVXpKNGdRU2F3R0FMR0haVjc0
 bk9BdFB0dG9aRFRzaDdCZUdDTEQvUHM3dlJ1Z3dEZHo5dVBBUlh6RjNiRC84cUNwdW12UkdiNHBla
 HpmUXNrK0ZuR2dUd2kwclVlVmFOOGE3S2J2OFpwUmZVMnNkKzIwOEYvWUw0MkJXQWgvMnR2MEk0dl
 k3WnNyQ1pjclVKdGdLV3k1TnIrdDc4em1Qa3Jac1gva2dmbkdkWGhyNTBrTjEwY21rTFEwL2NaT1h
 vOUNBa3BlWnlGdSt3UTV2UWRVYUVTMlZkNWtCakpZUENrcjRiMm9jcjRFVFFpM0lHTzJHR0NvQ2V0
 bU1JRVRzdWRSVlN4VU5CYnZhK1ZneGluNUFwdTR3SVAvMFp5dUdLNlR1V0xxTG5OcG1LM1JrUngwe
 GpxSjRuTjJPazB1bDBYWUJKY1lJQnQ0VW9hVk0ydVNhL0V0dzI4VXkrekFzVXYyQU9pUm81
{{< / highlight >}}

You can run `ldif-to-hashes.py`
{{< highlight txt >}}
~/projects/389ds-password-checker$ python ldif-to-hashes.py ./backup.ldif.example backup.ldif.hashes
username1:{PBKDF2_SHA256}AAAnEGTxXtnR/oox922/jZyjH6fmiIdW4AwIYZE2LfCVL/SUz5GbAHfjRj4NbN2u8ul0/j/dUzJ4gQSawGALGHZV74nOAtPttoZDTsh7BeGCLD/Ps7vRugwDdz9uPARXzF3bD/8qCpumvRGb4pehzfQsk+FnGgTwi0rUeVaN8a7Kbv8ZpRfU2sd+208F/YL42BWAh/2tv0I4vY7ZsrCZcrUJtgKWy5Nr+t78zmPkrZsX/kgfnGdXhr50kN10cmkLQ0/cZOXo9CAkpeZyFu+wQ5vQdUaES2Vd5kBjJYPCkr4b2ocr4ETQi3IGO2GGCoCetmMIETsudRVSxUNBbva+Vgxin5Apu4wIP/0ZyuGK6TuWLqLnNpmK3RkRx0xjqJ4nN2Ok0ul0XYBJcYIBt4UoaVM2uSa/Etw28Uy+zAsUv2AOiRo5
{{< / highlight >}}

And then run a basic test harness to check the password hashes against a list.
{{< highlight txt >}}
~/projects/389-testing/389ds-password-checker$ python3 389ds-pwdcheck-harness.py 389ds-pwdcheck.py guesses.txt backup.ldif.hashes 20
Loaded 1 user hashes...
Loaded 242 password to try..
username1:Password123
Elapsed time: 10.376861095428467 seconds
{{< / highlight >}}

Next stop - a jtr or hashcat module. Thanks for reading! Github repo is at https://github.com/thesubtlety/389-ds-password-check
