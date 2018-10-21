# Stop if things go wrong, so we can fix state and 
$ErrorActionPreference = 'STOP'

# start with clink so we can handle some post install things
# also git, which is needed for clink-completions
choco install clink git

# change to the clink script directory
cd $Env:LOCALAPPDATA/clink
# add clink-completions to the scripts directory
git init
git remote add origin https://github.com/vladimir-kotikov/clink-completions
git pull origin master
# we can leave the clink script directory
cd $PSScriptRoot
# replace the git-prompt.lua file with our own.
move $PSScriptRoot/git-prompt.lua $Env:LOCALAPPDATA/clink/git-prompt.lua

# Install a minimal Python 2, installing just the Tools 
# (not added to the path or registering for *.py)
# The names for this were not easy to find documentation for
# All I could find for the MSI customization arguments was
# https://www.python.org/download/releases/2.4/msi/

# TODO: figure out how to byte compile the stdlib?
choco install python2 -ia "ADDLOCAL=Tools"

# Install a more complete Python 3 (add to path, register extensions, etc)
# This will byte compile the standard library and include debug symbols
choco install python3 -ia "CompileAll=1 Include_debug=1 Include_symbols=1"

# Install openssh with the ssh-server functionality on
choco install openssh -params '"/SSHServerFeature"'

# Download and install zerotier, because sadly it is not available through chocolatey right now :(
curl --progress-bar "https://download.zerotier.com/dist/ZeroTier%20One.msi" -o "ZeroTierOne.msi"
msiexec "ZeroTierOne.msi" /quiet

# Download and install Rust nightly for Windows
curl --progress-bar "https://win.rustup.rs/x86_64" -o "rustup-init.exe"
rustup-init.exe --default-host x86_64-pc-windows-msvc --default-toolchain nightly

# Finally, install all the other programs I use:
&choco install @(type .\software.txt)