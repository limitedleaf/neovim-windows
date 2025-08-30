# nvim-bootstrap.ps1
# random test msg
$ErrorActionPreference = "Stop"

# Define paths
$nvimConfigPath = "$env:LOCALAPPDATA/nvim"
$repoUrl = "https://github.com/limitedleaf/neovim-windows"
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
$neededBuckets = @("nerd-fonts","main","versions","extras","java")
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

function Get-LatestRelease {
param (
		[string]$repoUrl
	)
	# Get the latest release from GitHub API
	$apiUrl = "$repoUrl/releases/latest"
	$response = Invoke-RestMethod -Uri $apiUrl
	$releaseTag = response.tag_name

	if ($releaseTag -like "release-*") {
		return $releaseTag
	} else {
		Write-Host "Invalid release format. Expected 'release-<version>'"
		return $null
	}
}

function Clone-LatestRelease {
param (
		[string]$repoUrl,
		[string]$nvimConfigPath,
		[string]$releaseTag
	)
	$releaseUrl = "https://github.com/limitedleaf/neovim-windows/releases/download"
	$downloadUrl = "$releaseUrl/$releaseTag/nvim-windows-$releaseTag.zip"
	$zipFile = "$env:TEMP\nvim-windows-$releaseTag.zip"
	$extractPath = $nvimConfigPath

	# Download the latest release zip
	Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
	Write-Host "Downloaded release $releaseTag."

	# Extract the zip file to the config path
	Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force
	Write-Host "Extracted release $releaseTag to $extractPath."


	# Clean up the zip file
	Remove-Item -Path $zipFile -Force
}

if (Test-Path "$nvimConfigPath\.git") {
	Write-Host "Repo already cloned. Emptying the directory and cloning the latest release..."

	# Empty the directory (Remove all files)
	Remove-Item -Path "$nvimConfigPath\*" -Recurse -Force -ErrorAction SilentlyContinue

	# Get the latest release tag
	$latestReleaseTag = Get-LatestRelease $repoUrl

	# Clone the latest release if the tag is found
	if ($latestReleaseTag) {
		Write-Host "Latest release tag is: $latestReleaseTag"
		Clone-LatestRelease $repoUrl $nvimConfigPath $latestReleaseTag
	} else {
		Write-Host "Failed to get the latest release. Ensure the repository and releases exist."
	}
} else {
	Write-Host "Repo not found. Cloning the repository..."

	# Clone the repository normally
	git clone $repoUrl $nvimConfigPath
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
