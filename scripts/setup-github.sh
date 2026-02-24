#!/usr/bin/env bash
# SKIDATA Scraper - GitHub Setup Script (for Git Bash)
# Run: bash scripts/setup-github.sh
# Prerequisites: Git and GitHub CLI (gh) installed and authenticated.

set -e
REPO_NAME="${1:-SKIDATA_Scraper}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "=== SKIDATA Scraper - GitHub Setup ==="
echo ""

# Check Git
if ! command -v git &> /dev/null; then
    echo "ERROR: Git is not installed or not in PATH."
    echo "Install from: https://git-scm.com/download/win"
    exit 1
fi

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "ERROR: GitHub CLI (gh) is not installed or not in PATH."
    echo "Install from: https://cli.github.com/"
    exit 1
fi

# Check gh authentication
if ! gh auth status &> /dev/null; then
    echo "ERROR: GitHub CLI is not authenticated."
    echo "Run: gh auth login"
    exit 1
fi

# Initialize git if needed
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
fi

# Add all files and commit
echo "Staging files..."
git add -A
git branch -M main 2>/dev/null || true
if [ -n "$(git status --porcelain)" ]; then
    git commit -m "Initial commit: SKIDATA scraper pipeline with GitHub Actions"
    echo "Committed changes."
else
    echo "Nothing to commit (all clean)."
fi

# Create GitHub repo and push
if [ -z "$(git config --get remote.origin.url 2>/dev/null)" ]; then
    echo "Creating GitHub repository '$REPO_NAME'..."
    gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
    echo "Repository created and pushed."
else
    echo "Remote 'origin' already exists. Pushing..."
    git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null
fi

# Set secrets from .env
if [ -f .env ]; then
    echo ""
    echo "Setting GitHub Actions secrets from .env..."
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        name=$(echo "${line%%=*}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo "${line#*=}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -z "$value" ]] && continue
        case "$name" in
            SKIDATA_URL|SKIDATA_TENANT|SKIDATA_LOGIN|SKIDATA_PASSWORD|TENANT_ID|CLIENT_ID|CLIENT_SECRET|SHAREPOINT_SITE_NAME|TARGET_FOLDER_PATH)
                echo "$value" | gh secret set "$name"
                echo "  Set: $name"
                ;;
        esac
    done < .env
    echo "Secrets configured."
else
    echo ""
    echo "WARNING: .env file not found. Add secrets manually in GitHub:"
    echo "  Settings -> Secrets and variables -> Actions"
fi

echo ""
echo "=== Done ==="
echo "Your workflow will run on schedule (daily 2 AM UTC) or trigger manually from the Actions tab."
