#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the GitHub Copilot modernize CLI.
.DESCRIPTION
    Downloads the latest modernize release for Windows, verifies the gh CLI
    version, extracts the binary, and adds it to the current user PATH.
.PARAMETER InstallDir
    Directory to install modernize into. Defaults to %LOCALAPPDATA%\Programs\modernize.
#>
[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'Programs' 'modernize')
)

$ErrorActionPreference = 'Stop'

$GitHubRepo    = 'microsoft/modernize-cli'
$MinGhVersion  = [Version]'2.45.0'

# --- Helpers ---

function Write-Info  { param([string]$Msg) Write-Host "[info]  $Msg" -ForegroundColor Green  }
function Write-Warn  { param([string]$Msg) Write-Host "[warn]  $Msg" -ForegroundColor Yellow }
function Exit-Error  { param([string]$Msg) Write-Host "[error] $Msg" -ForegroundColor Red; exit 1 }

# --- Detect architecture ---

$arch = switch ([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture) {
    'Arm64' { 'arm64' }
    default { 'x64'  }
}

Write-Info "Detected platform: windows/$arch"

# --- Check gh CLI version ---

if (Get-Command gh -ErrorAction SilentlyContinue) {
    $ghRaw = (gh --version 2>&1 | Select-Object -First 1) -as [string]
    if ($ghRaw -match '(\d+\.\d+\.\d+)') {
        $ghVersion = [Version]$Matches[1]
        if ($ghVersion -lt $MinGhVersion) {
            Write-Warn "gh CLI version $ghVersion is below the minimum required version $MinGhVersion."
            Write-Warn 'Please update gh CLI: https://cli.github.com/'
            $answer = Read-Host 'Continue anyway? [y/N]'
            if ($answer -notmatch '^[yY]') {
                Exit-Error 'Installation aborted.'
            }
        } else {
            Write-Info "gh CLI version $ghVersion OK"
        }
    } else {
        Write-Warn "Could not parse gh CLI version from: $ghRaw"
    }
} else {
    Write-Warn 'gh CLI not found. Please install it from https://cli.github.com/'
}

# --- Fetch latest release ---

Write-Info 'Fetching latest release...'

# Obtain a GitHub token via gh CLI (if available) for authenticated requests.
# This avoids rate-limiting without relying on the deprecated `gh release download`.
$ghToken = $null
if (Get-Command gh -ErrorAction SilentlyContinue) {
    $ghToken = (gh auth token 2>$null)
}

$apiHeaders = @{ Accept = 'application/vnd.github+json'; 'User-Agent' = 'modernize-installer' }
if ($ghToken) { $apiHeaders['Authorization'] = "Bearer $ghToken" }

try {
    $release = Invoke-RestMethod `
        -Uri     "https://api.github.com/repos/$GitHubRepo/releases/latest" `
        -Headers $apiHeaders
} catch {
    Exit-Error "Failed to fetch release info from GitHub: $_"
}

$tag     = $release.tag_name
$version = $tag -replace '^v', ''

if (-not $version) { Exit-Error 'Could not determine latest version.' }
Write-Info "Latest version: $version"

# --- Download ---

$archiveName  = "modernize_${version}_windows_${arch}.zip"
$downloadUrl  = "https://github.com/$GitHubRepo/releases/download/$tag/$archiveName"

$tmpDir      = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
$archivePath = Join-Path $tmpDir $archiveName
New-Item -ItemType Directory -Path $tmpDir | Out-Null

# Locate the asset's GitHub API URL in the release data. Downloading via the
# browser URL (github.com/releases/download/...) with a token causes GitHub to
# redirect to a CDN that expects auth in URL query params. PowerShell/curl
# typically strip the Authorization header on cross-host redirects, causing 404.
# The API asset endpoint (with Accept: application/octet-stream) returns a
# pre-signed CDN URL so the download follows the redirect cleanly.
$assetApiUrl = $null
if ($ghToken) {
    $assetApiUrl = ($release.assets | Where-Object { $_.name -eq $archiveName } | Select-Object -First 1).url
}

try {
    if ($assetApiUrl) {
        Write-Info "Downloading $archiveName..."
        try {
            Invoke-WebRequest -Uri $assetApiUrl -OutFile $archivePath -UseBasicParsing `
                -Headers @{ Authorization = "Bearer $ghToken"; Accept = 'application/octet-stream' }
        } catch {
            Exit-Error "Download failed: $_"
        }
    } else {
        Write-Info "Downloading $downloadUrl..."
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing
        } catch {
            Exit-Error "Download failed: $_"
        }
    }

    # --- Extract ---

    Write-Info 'Extracting archive...'
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    try {
        Expand-Archive -Path $archivePath -DestinationPath $InstallDir -Force
    } catch {
        Exit-Error "Failed to extract archive: $_"
    }

    Write-Info "Installed modernize to $InstallDir"
} finally {
    Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
}

# --- Add to user PATH ---

$userPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User')
if ($userPath -split ';' -contains $InstallDir) {
    Write-Info "$InstallDir is already in PATH"
} else {
    Write-Info "Adding $InstallDir to user PATH..."
    $newPath = ($userPath.TrimEnd(';') + ";$InstallDir").TrimStart(';')
    [System.Environment]::SetEnvironmentVariable('PATH', $newPath, 'User')
    # Also update the current session
    $env:PATH = ($env:PATH.TrimEnd(';') + ";$InstallDir")
    Write-Info 'PATH updated. The change will apply to new terminal sessions.'
}

Write-Host ''
Write-Info "Installation complete! Run 'modernize' to get started."
