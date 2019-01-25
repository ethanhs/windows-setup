# Stop if things go wrong, so we can fix state and 
$ErrorActionPreference = 'STOP'

# make installs easier
choco feature enable -n allowGlobalConfirmation

# start with clink so we can handle some post install things
# also git, which is needed for clink-completions
choco install clink
choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
refreshenv
# change to the clink script directory
cd $Env:LOCALAPPDATA/clink
# add clink-completions to the scripts directory
git init
git remote add origin https://github.com/vladimir-kotikov/clink-completions
git pull origin master
# we can leave the clink script directory
cd $PSScriptRoot
# replace the git-prompt.lua file with our own.
$promptpath = Join-Path -Path $PSScriptRoot -ChildPath git_prompt.lua
if([System.IO.File]::Exists($promptpath)){
    # if it doesn't exist, we have already moved it (the script may have been run already)
    move $PSScriptRoot/git_prompt.lua $Env:LOCALAPPDATA/clink/git_prompt.lua
}

# Install everything search, the best search tool that exists for Windows
choco install everything /client-service

# Install a minimal Python 2, installing just the Tools 
# (not added to the path or registering for *.py)
# The names for this were not easy to find documentation for
# All I could find for the MSI customization arguments was
# https://www.python.org/download/releases/2.4/msi/

# TODO: figure out how to byte compile the stdlib?
choco install python2 -ia "ADDLOCAL=Tools"
refreshenv

# Install a more complete Python 3 (add to path, register extensions, etc)
# This will byte compile the standard library and include debug symbols
choco install python3 -ia "CompileAll=1 Include_debug=1 Include_symbols=1"
refreshenv

# Install openssh with the ssh-server functionality on
choco install openssh -params '"/SSHServerFeature"'
refreshenv

# Now install VS 2017
choco install visualstudio2017community

# and the customized workloads I would like to use
choco install visualstudio2017-workload-visualstudioextension visualstudio2017-workload-nativedesktop visualstudio2017-workload-nativecrossplat visualstudio2017-workload-data
choco install visualstudio2017-workload-netcoretools --package-paramters "--includeOptional"
choco install visualstudio2017-workload-manageddesktop --package-paramters "--includeOptional"
refreshenv

# install the best search program ever
choco install everything /client-service /efu-association /folder-context-menu

# Install Zerotier if it isn't already
$ztpath = Join-Path -Path $PSScriptRoot -ChildPath ZeroTierOne.msi.exe
if(![System.IO.File]::Exists($ztpath)){
    # Download and install zerotier, because sadly it is not available through chocolatey right now :(
    curl.exe --progress-bar "https://download.zerotier.com/dist/ZeroTier%20One.msi" -o "ZeroTierOne.msi"
    msiexec /i "ZeroTierOne.msi" /qn
}

# Install firefox if it isn't already
$ffpath = Join-Path -Path $PSScriptRoot -ChildPath FirefoxInstaller.exe
if(![System.IO.File]::Exists($ffpath)){
    curl.exe --progress-bar "https://archive.mozilla.org/pub/firefox/nightly/latest-mozilla-central/Firefox%20Installer.en-US.exe" -o "Firefo
xInstaller.exe"
    # Sadly this creates a GUI, and then opens firefox, but meh
    .\FirefoxInstaller.exe
}

$rspath = Join-Path -Path $PSScriptRoot -ChildPath rustup-init.exe
if(![System.IO.File]::Exists($rspath)){
    # Download and install Rust nightly for Windows
    curl.exe --progress-bar "https://win.rustup.rs/x86_64" -o "rustup-init.exe"
    .\rustup-init.exe --default-host=x86_64-pc-windows-msvc --default-toolchain=nightly -y
    refreshenv
}

# Do some environment setup etc
Enable-WindowsOptionalFeature -Online -FeatureName containers -All
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0
Set-ItemProperty $key ShowSuperHidden 1
Stop-Process -processname explorer
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1
RefreshEnv

# Add important Windows features and install WSL
if(![System.IO.File]::Exists("~/Ubuntu.appx")) {
    Write-Host "Installing Ubuntu 18.04 into the WSL.. (see progress at top)" -ForegroundColor "Yellow"
    choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"
    choco install -y Microsoft-Hyper-V-All --source="'windowsFeatures'"
    refreshenv

    # Install the WSL with Ubuntu 18.04

    Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
    Add-AppxPackage -Path ~/Ubuntu.appx
    RefreshEnv
    Ubuntu1804 install --root
    Ubuntu1804 run apt update
    Ubuntu1804 run apt upgrade -y
}

# Finally, install all the other programs I use:
&choco install @(type .\software.txt)
choco install nvidia-display-driver spotify --ignore-checksums

refreshenv

#### Remove unneeded apps, copied/modified from https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/scripts/RemoveDefaultApps.ps1

#--- Uninstall unecessary applications that come with Windows out of the box ---
Write-Host "Uninstall some applications that come with Windows out of the box" -ForegroundColor "Yellow"

#Referenced to build script
# https://docs.microsoft.com/en-us/windows/application-management/remove-provisioned-apps-during-update
# https://github.com/jayharris/dotfiles-windows/blob/master/windows.ps1#L157
# https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
# https://gist.github.com/alirobe/7f3b34ad89a159e6daa1
# https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/remove-default-apps.ps1

function removeApp {
	Param ([string]$appName)
	Write-Output "Trying to remove $appName"
	Get-AppxPackage $appName -AllUsers | Remove-AppxPackage
	Get-AppXProvisionedPackage -Online | Where DisplayNam -like $appName | Remove-AppxProvisionedPackage -Online
}

$applicationList = @(
	"Microsoft.BingFinance"
	"Microsoft.3DBuilder"
	"Microsoft.BingFinance"
	"Microsoft.BingNews"
	"Microsoft.BingSports"
	"Microsoft.BingWeather"
	"Microsoft.CommsPhone"
	"Microsoft.Getstarted"
	"Microsoft.WindowsMaps"
	"*MarchofEmpires*"
	"Microsoft.GetHelp"
	"Microsoft.Messaging"
	"*Minecraft*"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.OneConnect"
	"Microsoft.WindowsPhone"
	"*Solitaire*"
	"Microsoft.Office.Sway"
	"Microsoft.XboxApp"
	"Microsoft.XboxIdentityProvider"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"Microsoft.NetworkSpeedTest"
	"Microsoft.FreshPaint"
	"Microsoft.Print3D"
	"*Autodesk*"
	"*BubbleWitch*"
    "king.com*"
    "G5*"
	"*Dell*"
	"*Facebook*"
	"*Keeper*"
	"*Netflix*"
	"*Twitter*"
	"*Plex*"
	"*.Duolingo-LearnLanguagesforFree"
	"*.EclipseManager"
	"ActiproSoftwareLLC.562882FEEB491" # Code Writer
	"*.AdobePhotoshopExpress"
);

foreach ($app in $applicationList) {
    removeApp $app
}