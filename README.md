# My Windows Setup

After having to re-install Windows a few times too many in the past year (don't
ask), so I decided to write up my setup and link to useful things I use,
partially for myself, partially if anyone else finds it useful. I am not
affiliated with, nor paid by any of the below. Several of these tools and
methods I dive deeper into as they give a more unix like feel and are great for
developers.

Make sure to read the `install.ps1`! I haven't used it yet (I wrote it for next
time) but hopefully it works well for others.

### Chocolatey

First off, I use chocolatey, it is quite possibly the best tool I have on this
list. Package managers are awesome. It makes things so much nicer. Use it!
https://chocolatey.org/

### Clink

[Clink](https://github.com/mridgers/clink) gives really nice tab completion for
command prompt and powershell. I install it through chocolatey.

To make it even better, I have used the wonderful
[clink-completions](https://github.com/vladimir-kotikov/clink-completions) repo
to add nice completions for many programs.

I decided I want my own style of prompt, so I replace `git_prompt.lua` with my
own (less intrusive) `git-prompt.lua`, which can be found in this repo.

### SSH server

I want to have remote access to my desktop at times over ZeroTier. When you
install the `openssh` package through Chocolatey, make sure to use the `-params
'"/SSHServerFeature"'` flag so that you can get the ssh server running.

([source for more about the openssh
package](https://github.com/DarwinJS/ChocoPackages/blob/master/openssh/readme.md))

### Python

I work on Python projects like [mypy](https://github.com/python/mypy). For this,
I need both Python 3 and Python 2. To acheive this, I use the `python3` and
`python2` packages from chocolatey.

I customize these installs by passing `-ia "ADDLOCAL=Tools"` for Python 2 and
`-ia "CompileAll=1 Include_debug=1 Include_symbols=1"` for Python 3.

#### TODO

- Firefox
- SSH
- GPG