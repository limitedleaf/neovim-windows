# nvim-bootstrap.ps1

$ErrorActionPreference = "Stop"

# Define paths
$nvimConfigPath = "$env:LOCALAPPDATA/nvim"
$repoUrl = "https://github.com/limitedleaf/neovim-windows"
$scoopfile = Join-Path $nvimConfigPath "dependencies.json"
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Verify scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
	Write-Host "Scoop not found. Installing Scoop..."
	Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
	Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
	Write-Host "Scoop already installed"
}

# Install nvim
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Host "Neovim not found. Installing Neovim with Scoop..."
    scoop install neovim
} else {
    Write-Host "Neovim already installed."
}


# Install dependencies
Write-Host "Installing dependencies..."

# Install Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found. Installing Git..."
    scoop install git
} else {
    Write-Host "Git already installed."
}

# Add Buckets
if (-not (scoop bucket list | Select-String "nerd-fonts")) {
    scoop bucket add nerd-fonts
}
if (-not (scoop bucket list | Select-String "main")) {
    scoop bucket add main
}
if (-not (scoop bucket list | Select-String "versions")) {
    scoop bucket add versions
}
if (-not (scoop bucket list | Select-String "extras")) {
    scoop bucket add extras
}

# Create nvim dir
if (-not (Test-Path $nvimConfigPath)) {
    Write-Host "Creating Neovim config folder at $nvimConfigPath"
    New-Item -ItemType Directory -Path $nvimConfigPath | Out-Null
} else {
    Write-Host "Neovim config folder already exists."
}

# Clone git repo
if (-not (Test-Path "$nvimConfigPath\.git")) {
    Write-Host "Cloning Neovim config repo..."
    git clone $repoUrl $nvimConfigPath
} else {
    Write-Host "Repo already cloned. Pulling latest changes..."
    git -C $nvimConfigPath pull
}

# Install a nerdFont
if (-not (scoop list | Select-String "JetBrainsMono-NF")) {
    scoop install JetBrainsMono-NF
    Write-Host "JetBrainsMono Nerd Font Font installed."
} else {
    Write-Host "JetBrainsMono Nerd Font already installed."
}

if (Test-Path $wtSettings) {
    $settings = Get-Content $wtSettings -Raw | ConvertFrom-Json

    foreach ($profile in $settings.profiles.list) {
        if ($profile.name -like "*PowerShell*") {
            if (-not $profile.font) {
                $profile | Add-Member -MemberType NoteProperty -Name font -Value @{ face = "JetBrainsMono Nerd Font" }
            } else {
                $profile.font.face = "JetBrainsMono Nerd Font"
            }
        }
    }

    $settings | ConvertTo-Json -Depth 5 | Set-Content $wtSettings
    Write-Host "Windows Terminal font updated. Restart terminal to apply."
} else {
    Write-Host "Windows Terminal settings.json not found. Set the font manually."
}

#Install pip
if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Host "pip not found. Installing Git..."
    scoop install python
} else {
    Write-Host "pip already installed."
}

#Install luarocks
if (-not (Get-Command luarocks -ErrorAction SilentlyContinue)) {
    Write-Host "luarocks not found. Installing Git..."
    scoop install luarocks
} else {
    Write-Host "luarocks already installed."
}

#Install nodejs
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "nodejs not found. Installing Git..."
    scoop install nodejs
} else {
    Write-Host "nodejs already installed."
}

#Install ripgrep
if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
    Write-Host "ripgrep not found. Installing Git..."
    scoop install ripgrep
} else {
    Write-Host "ripgrep already installed."
}

#Install lua5.1
if (-not (Get-Command lua5.1 -ErrorAction SilentlyContinue)) {
    Write-Host "lua5.1 not found. Installing Git..."
    scoop install lua51
    scoop shim add lua5.1 "$env:USERPROFILE\scoop\apps\lua51\current\lua5.1.exe"
} else {
    Write-Host "lua5.1 already installed."
}

Write-Host "Installed dependencies!"

# Setup Providers
pip install pynvim
npm install neovim
