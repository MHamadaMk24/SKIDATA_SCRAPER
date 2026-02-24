# SKIDATA Scraper

Scrapes reports from SKIDATA analytics, cleans them, and uploads to Microsoft SharePoint. Runs on a schedule via GitHub Actions.

## Pipeline

1. **Scraper** – Logs into SKIDATA portal, downloads Revenue, Access, System Event, and Parking reports to `exports/`
2. **Transformer** – Cleans Excel files (removes Totals/blank rows), moves to `Cleaned-Exports/`
3. **SharePoint** – Uploads cleaned files to your SharePoint site

## Local Setup

```bash
pip install -r requirements.txt
playwright install chromium
```

Copy `.env.example` to `.env` and fill in your credentials.

## Run Locally

```bash
python main.py
```

## GitHub Setup

### 1. Install prerequisites

- **Git**: https://git-scm.com/download/win  
- **GitHub CLI**: https://cli.github.com/

### 2. Log in to GitHub

```powershell
gh auth login
```

### 3. Run the setup script

**From Git Bash:**
```bash
bash scripts/setup-github.sh
```

**From PowerShell:**
```powershell
.\scripts\setup-github.ps1
```

This will:
- Initialize git (if needed)
- Create a GitHub repository
- Push your code
- Set secrets from `.env`

### 4. Create repo manually (if not using the script)

1. Create a new repo at https://github.com/new
2. Add remote and push:

   ```powershell
   git init
   git add -A
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/SKIDATA_Scraper.git
   git push -u origin main
   ```

3. Add secrets: **Settings → Secrets and variables → Actions → New repository secret**

   | Secret               | Required |
   |----------------------|----------|
   | SKIDATA_URL          | Yes      |
   | SKIDATA_TENANT       | Yes      |
   | SKIDATA_LOGIN        | Yes      |
   | SKIDATA_PASSWORD     | Yes      |
   | TENANT_ID            | Yes      |
   | CLIENT_ID            | Yes      |
   | CLIENT_SECRET        | Yes      |
   | SHAREPOINT_SITE_NAME | Yes      |
   | TARGET_FOLDER_PATH   | No (default: SKIDATA-Cleaned-Exports) |

## Schedule

The workflow runs **daily at 2:00 AM UTC**. You can also trigger it manually from the **Actions** tab.
