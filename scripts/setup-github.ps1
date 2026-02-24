# SKIDATA Scraper - GitHub Setup Script
# Run this script to push the project to GitHub and configure secrets.
# Prerequisites: Git and GitHub CLI (gh) installed and authenticated.

param(
    [string]$RepoName = "SKIDATA_Scraper",
    [switch]$Private = $false
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $ProjectRoot

Write-Host "=== SKIDATA Scraper - GitHub Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Git is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Install from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Check GitHub CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: GitHub CLI (gh) is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Install from: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

# Check gh authentication
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: GitHub CLI is not authenticated." -ForegroundColor Red
    Write-Host "Run: gh auth login" -ForegroundColor Yellow
    exit 1
}

# Initialize git if needed
if (-not (Test-Path ".git")) {
    Write-Host "Initializing git repository..." -ForegroundColor Green
    git init
}

# Add all files and commit
Write-Host "Staging files..." -ForegroundColor Green
git add -A
git branch -M main 2>$null
$status = git status --porcelain
if ($status) {
    git commit -m "Initial commit: SKIDATA scraper pipeline with GitHub Actions"
    Write-Host "Committed changes." -ForegroundColor Green
} else {
    Write-Host "Nothing to commit (all clean)." -ForegroundColor Yellow
}

# Create GitHub repo and push
$remoteUrl = git config --get remote.origin.url 2>$null
if (-not $remoteUrl) {
    Write-Host "Creating GitHub repository '$RepoName'..." -ForegroundColor Green
    $visibility = if ($Private) { "--private" } else { "--public" }
    gh repo create $RepoName $visibility --source=. --remote=origin --push
    Write-Host "Repository created and pushed." -ForegroundColor Green
} else {
    Write-Host "Remote 'origin' already exists. Pushing..." -ForegroundColor Green
    git push -u origin main 2>$null
    if ($LASTEXITCODE -ne 0) {
        git push -u origin master 2>$null
    }
}

# Set secrets from .env
$envFile = Join-Path $ProjectRoot ".env"
if (Test-Path $envFile) {
    Write-Host ""
    Write-Host "Setting GitHub Actions secrets from .env..." -ForegroundColor Green
    $envContent = Get-Content $envFile
    $secretNames = @(
        "SKIDATA_URL", "SKIDATA_TENANT", "SKIDATA_LOGIN", "SKIDATA_PASSWORD",
        "TENANT_ID", "CLIENT_ID", "CLIENT_SECRET",
        "SHAREPOINT_SITE_NAME", "TARGET_FOLDER_PATH"
    )
    foreach ($line in $envContent) {
        if ($line -match "^\s*#") { continue }
        if ($line -match "^([^=]+)=(.*)$") {
            $name = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            if ($secretNames -contains $name -and $value) {
                $value | gh secret set $name
                Write-Host "  Set: $name" -ForegroundColor Gray
            }
        }
    }
    Write-Host "Secrets configured." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "WARNING: .env file not found. Add secrets manually in GitHub:" -ForegroundColor Yellow
    Write-Host "  Settings -> Secrets and variables -> Actions" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host "Your workflow will run on schedule (daily 2 AM UTC) or trigger manually from the Actions tab."
