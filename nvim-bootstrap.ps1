# nvim-bootstrap.ps1
$ErrorActionPreference = "Stop"

# Define paths
$nvimConfigPath = "$env:LOCALAPPDATA/nvim"
$repoUrl = "https://github.com/limitedleaf/neovim-windows"
$scoopfile = Join-Path $nvimConfigPath "dependencies.json"
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Function to check/install packages
function Ensure-Command {
    param(
        [string]$CommandName,
        [string]$PackageName
    )
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        Write-Host "$CommandName not found. Installing $PackageName..."
        scoop install $PackageName
    } else {
        Write-Host "$CommandName already installed."
    }
}

# Verify scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop not found. Installing Scoop..."
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "Scoop already installed"
}

# Install Neovim
Ensure-Command -CommandName "nvim" -PackageName "neovim"

# Install Git
Ensure-Command -CommandName "git" -PackageName "git"

# Add Buckets
$neededBuckets = @("nerd-fonts","main","versions","extras")
foreach ($bucket in $neededBuckets) {
    if (-not (scoop bucket list | Select-String $bucket)) {
        scoop bucket add $bucket
    }
}

# Create nvim config folder
if (-not (Test-Path $nvimConfigPath)) {
    Write-Host "Creating Neovim config folder at $nvimConfigPath"
    New-Item -ItemType Directory -Path $nvimConfigPath | Out-Null
} else {
    Write-Host "Neovim config folder already exists."
}

# Clone or pull repo
if (-not (Test-Path "$nvimConfigPath\.git")) {
    Write-Host "Cloning Neovim config repo..."
    git clone $repoUrl $nvimConfigPath
} else {
    Write-Host "Repo already cloned. Pulling latest changes..."
    git -C $nvimConfigPath pull
}

# Install Nerd Font
Ensure-Command -CommandName "JetBrainsMono-NF" -PackageName "JetBrainsMono-NF"

# Update Windows Terminal font
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

# Install common dependencies
Ensure-Command -CommandName "pip" -PackageName "python"
Ensure-Command -CommandName "luarocks" -PackageName "luarocks"
Ensure-Command -CommandName "node" -PackageName "nodejs"
Ensure-Command -CommandName "rg" -PackageName "ripgrep"
Ensure-Command -CommandName "lua5.1" -PackageName "lua51"
# Add shim for lua5.1 if installed
if (Test-Path "$env:USERPROFILE\scoop\apps\lua51\current\lua5.1.exe") {
    scoop shim add lua5.1 "$env:USERPROFILE\scoop\apps\lua51\current\lua5.1.exe"
}
Ensure-Command -CommandName "lazygit" -PackageName "lazygit"
Ensure-Command -CommandName "fd" -PackageName "fd"
Ensure-Command -CommandName "gcc" -PackageName "gcc"
Ensure-Command -CommandName "tree-sitter" -PackageName "tree-sitter"

Write-Host "Installed dependencies!"

# Setup Providers
pip install pynvim
npm install -g neovim
