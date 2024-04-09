#region Installation

#region Install on Windows

# PowerShell 7 installs side-by-side on Windows with Windows PowerShell. It doesn't replace Windows PowerShell 5.1. The name of the executables are different. powershell.exe is Windows PowerShell, and pwsh.exe is PowerShell 7.

<#
    If you don't have PowerShell version 7 installed, open Windows PowerShell and use Windows Package Manager (Winget) to install the latest version of PowerShell.
#>

# Update Winget

Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile $HOME/Downloads/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Add-AppxPackage $HOME/Downloads/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

# Install PowerShell 7

winget install --id Microsoft.Powershell --source winget

# Install VS Code

winget install --id Microsoft.VisualStudioCode --source winget

<#
    The PowerShell ISE only works with Windows PowerShell. It's also no longer in active feature development. You only need to install it on the computer where you create PowerShell scripts. You don’t need to install them on all the computers where you run PowerShell.
#>

# Reload the environment variables to include the new path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install the PowerShell extension for VS Code

code --install-extension ms-vscode.powershell

# Install Windows Terminal

winget install --id Microsoft.WindowsTerminal --source winget

#endregion

#region Install on Linux

<#
    Install PowerShell on Ubuntu Linux using the Advanced Packaging Tool (apt) and the Bash
    command line.
#>

# Update the list of packages
sudo apt-get update

# Install prerequisite packages
sudo apt-get install -y wget apt-transport-https software-properties-common

# Get the version of Ubuntu
source /etc/os-release

# Download the Microsoft repository keys
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb

# Register the Microsoft repository keys
sudo dpkg -i packages-microsoft-prod.deb

# Delete the Microsoft repository keys file
rm packages-microsoft-prod.deb

# Update the list of packages after we added packages.microsoft.com
sudo apt-get update

# Install PowerShell
sudo apt-get install -y powershell

# Start PowerShell
pwsh

# Install VS Code

sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo apt install apt-transport-https
sudo apt update
sudo apt install code

# Install the PowerShell extension for VS Code

code --install-extension ms-vscode.powershell

#endregion

#region Install on macOS

<#
    On macOS, install PowerShell using the Homebrew package manager.
#>

# Install the Homebrew package manager.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

# Install the latest stable release of PowerShell:
brew install powershell/tap/powershell

#Start PowerShell to verify that it installed successfully:
pwsh

# Install VS Code

brew install --cask visual-studio-code

# Install the PowerShell extension for VS Code

code --install-extension ms-vscode.powershell

#endregion

#endregion