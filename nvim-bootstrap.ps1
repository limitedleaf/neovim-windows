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


# Verify Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found. Installing Git..."
    scoop install git
} else {
    Write-Host "Git already installed."
}


# Install a nerdFont
if (-not (scoop bucket list | Select-String "nerd-fonts")) {
    scoop bucket add nerd-fonts
}

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


# Install nvim
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Host "Neovim not found. Installing Neovim with Scoop..."
    scoop install neovim
} else {
    Write-Host "Neovim already installed."
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


# Install dependencies
Write-Host "Installing dependencies..."
scoop bucket add versions
scoop bucket add extras
scoop install python
scoop install lua51
scoop install luarocks
scoop install nodejs
Write-Host "Installed dependencies!"

# Setup providers 
npm install -g neovim
pip install pynvim

