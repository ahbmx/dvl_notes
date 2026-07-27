<#
.SYNOPSIS
  Automates local setup for the dvl_notes Obsidian + MkDocs Material + GitHub Pages workflow.

.DESCRIPTION
  Run this from anywhere. It will:
    1. Clone the repo (if not already present) to C:\Users\dvl\Documents\GitHub\dvl_notes
    2. Create/activate a Python venv and install mkdocs-material + plugins
    3. Commit and push the initial site files
    4. Try to enable GitHub Pages (branch: gh-pages) automatically via GitHub CLI, if installed/authenticated
    5. Trigger the first deploy and open the live preview locally

.NOTES
  - Requires: git, python 3.9+, (optional) GitHub CLI `gh` for step 4 automation.
  - Copy the files this script sits alongside (mkdocs.yml, requirements.txt,
    .github/, docs/, .gitignore) into the repo root before running.
#>

$ErrorActionPreference = "Stop"

$RepoUrl  = "https://github.com/ahbmx/dvl_notes.git"
$RepoPath = "C:\Users\dvl\Documents\GitHub\dvl_notes"

Write-Host "== 1. Repo ==" -ForegroundColor Cyan
if (-not (Test-Path $RepoPath)) {
    $parent = Split-Path $RepoPath -Parent
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    git clone $RepoUrl $RepoPath
} else {
    Write-Host "Repo already exists at $RepoPath, pulling latest..."
    Push-Location $RepoPath
    git pull
    Pop-Location
}

Set-Location $RepoPath

Write-Host "== 2. Copy scaffold files into repo (if not already there) ==" -ForegroundColor Cyan
$scaffoldSrc = $PSScriptRoot
foreach ($item in @("mkdocs.yml", "requirements.txt", ".gitignore", "docs", ".github")) {
    $src = Join-Path $scaffoldSrc $item
    $dst = Join-Path $RepoPath $item
    if ((Test-Path $src) -and -not (Test-Path $dst)) {
        Copy-Item $src $dst -Recurse
        Write-Host "Copied $item"
    }
}

Write-Host "== 3. Python venv ==" -ForegroundColor Cyan
if (-not (Test-Path ".\.venv")) {
    python -m venv .venv
}
& .\.venv\Scripts\Activate.ps1
pip install --upgrade pip | Out-Null
pip install -r requirements.txt

Write-Host "== 4. Commit & push ==" -ForegroundColor Cyan
git add -A
$status = git status --porcelain
if ($status) {
    git commit -m "Initial mkdocs-material + Obsidian vault setup"
    git branch -M main
    git push -u origin main
} else {
    Write-Host "Nothing to commit."
}

Write-Host "== 5. Enable GitHub Pages (gh-pages branch) ==" -ForegroundColor Cyan
if (Get-Command gh -ErrorAction SilentlyContinue) {
    try {
        gh api repos/ahbmx/dvl_notes/pages -X POST -f "source[branch]=gh-pages" -f "source[path]=/" 2>$null
        Write-Host "GitHub Pages configured (or already was)." -ForegroundColor Green
    } catch {
        Write-Host "Could not auto-configure Pages via API (it may already be set, or the gh-pages branch doesn't exist yet)." -ForegroundColor Yellow
        Write-Host "It will be created automatically after the first Actions run/deploy."
    }
} else {
    Write-Host "GitHub CLI (gh) not found. After the first Actions deploy creates the 'gh-pages' branch," -ForegroundColor Yellow
    Write-Host "go to Settings > Pages on GitHub and set Source = 'gh-pages' branch (one-time, ~30 sec)."
}

Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Push triggers the GitHub Action which builds and deploys automatically."
Write-Host "Site will be live at: https://ahbmx.github.io/dvl_notes/"
Write-Host ""
Write-Host "To preview locally: .\.venv\Scripts\Activate.ps1 ; mkdocs serve"
