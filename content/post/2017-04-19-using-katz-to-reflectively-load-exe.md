+++
date = "2017-04-19T18:19:01-07:00"
title = "Using subTee's katz to Reflectively Load an exe"
draft = false

+++

I haven't seen this specifically outlined anywhere so I figured I'd write a short post to go over using subTee's [Katz2.0](https://github.com/subTee/Utils) program to create a custom binary that loads mimikatz (or whatever executable you'd like) into memory. Casey Smith ([subTee](https://github.com/subTee)) and company have created some incredible tools that have made my life easier, so hats off to them.

### Reflective Injection

The following steps will create a custom binary with an encrypted and encoded mimikatz binary string which will load mimikatz into memory through [reflective PE injection](https://clymb3r.wordpress.com/2013/04/06/reflective-dll-injection-with-powershell/).

1. Compile [Mimikatz](https://github.com/gentilkiwi/mimikatz) for release - remember it's architecture specific so you'll probably want to compile both or download the binaries
1. Download subTee's [Katz2.0](https://github.com/subTee/Utils). [My fork](https://github.com/thesubtlety/Utils/blob/master/katz2.0.cs) simply makes the encryption method easier to access and outputs the base64. The following is based on that.
1. Open in Visual Studio
  1. Find/Replace "password" with something more subtle like "WaitForSingleObject"
  1. Find "SALT" and replace those bytes with `0xde 0xad 0xbe 0xef` and so on.
  1. Compile Katz2.0
1. And run the resulting binary pointing to your mimikatz executable
  1. `c:\>katz.exe encrypt c:\path\to\mimikatz64.exe | clip`
1. If you `clip`d from before this will be in your clipboard, otherwise copy the output string from newly created `file.b64`
1. Paste that string into the `filex64` variable (at the bottom of Katz2.0.cs)
1. And now rebuild Katz2.0 again
0. Note that you could/should repeat this process for the x86 mimikatz binary

Now when you run the katz2.0 binary without any arguments, mimikatz should be loaded into memory and run without issue. This will get by most AV out there although some programs may flag some mimikatz functionality (e.g. dumping `sekurlsa::logonpasswords`).


### Similar projects

* [p0wnedShell](https://github.com/Cn33liz/p0wnedShell) is pretty sweet, and does a similar thing although it's considerably larger including more tools

* Customize mimikatz to reflectively load the DLL into memory - great post [here](https://clymb3r.wordpress.com/2013/04/09/modifying-mimikatz-to-be-loaded-using-invoke-reflectivedllinjection-ps1/)

* Similar work by subTee lets you execute shellcode using JScript [here](https://subt0x10.blogspot.com/2017/04/using-dotnettojscript-working-example.html)

* For more fully featured obfuscation, [ObfuscatedEmpire](https://cobbr.io/ObfuscatedEmpire.html) is an awesome integration of Invoke-Obfuscation and Empire. Highly recommend checking it out.

* Similar but using `Invoke-Mimikatz` - simply make a few string modifications to slip by AV - [BHIS](http://www.blackhillsinfosec.com/?p=5555)

* Powershell without powershell.exe - [Also by BHIS](http://www.blackhillsinfosec.com/?p=5257)