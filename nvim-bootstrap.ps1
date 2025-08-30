$ErrorActionPreference = "Stop"

# Define paths
$nvimConfigPath = "$env:LOCALAPPDATA/nvim"
$repoUrl = "https://github.com/limitedleaf/neovim-windows"
$apiUrl = "https://api.github.com/repos/limitedleaf/neovim-windows/releases/latest"
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
$neededBuckets = @("nerd-fonts", "main", "versions", "extras", "java")
foreach ($bucket in $neededBuckets) {
    if (-not (scoop bucket list | Select-String $bucket)) {
        scoop bucket add $bucket
    }
}

#Update vcredist2022
scoop install vcredist2022
scoop uninstall vcredist2022

# Create nvim config folder
if (-not (Test-Path $nvimConfigPath)) {
    Write-Host "Creating Neovim config folder at $nvimConfigPath"
    New-Item -ItemType Directory -Path $nvimConfigPath | Out-Null
} else {
    Write-Host "Neovim config folder already exists."
}

# Function to fetch the latest release tag from GitHub
function Get-LatestReleaseTag {
    param (
        [string]$apiUrl
    )

    # Get the latest release from GitHub API
    $response = Invoke-RestMethod -Uri $apiUrl
    $releaseTag = $response.tag_name
    Write-Host "Latest release tag: $releaseTag"

    return $releaseTag
}

# Completely remove the existing repo (including .git)
if (Test-Path "$nvimConfigPath") {
    Write-Host "Removing existing Neovim config folder and all its contents..."
    Remove-Item -Path "$nvimConfigPath" -Recurse -Force
}

# Get the latest release tag
$releaseTag = Get-LatestReleaseTag $apiUrl

# Clone the repository and checkout the latest release
if ($releaseTag) {
    Write-Host "Cloning the repository and checking out to release $releaseTag..."
    git clone $repoUrl $nvimConfigPath
    # Checkout to the latest release tag
    git -C $nvimConfigPath checkout $releaseTag
} else {
    Write-Host "No release tag found."
}

# Install Nerd Font
if (-not (scoop list | Select-String "JetBrainsMono-NF")) {
    scoop install JetBrainsMono-NF
    Write-Host "JetBrainsMono Nerd Font Font installed."
} else {
    Write-Host "JetBrainsMono Nerd Font already installed."
}


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
Ensure-Command -CommandName "gzip" -PackageName "gzip"
Ensure-Command -CommandName "cargo" -PackageName "rustup"
Ensure-Command -CommandName "unzip" -PackageName "unzip"
Ensure-Command -CommandName "go" -PackageName "go"
Ensure-Command -CommandName "php" -PackageName "php"
Ensure-Command -CommandName "composer" -PackageName "composer"
Ensure-Command -CommandName "javac" -PackageName "openjdk"
Ensure-Command -CommandName "gem" -PackageName "ruby"
Ensure-Command -CommandName "julia" -PackageName "julia"
scoop install wget
Write-Host "Installed dependencies!"

# Setup Providers
pip install pynvim
npm install -g neovim
