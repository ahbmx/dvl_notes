# dvl_notes

Storage admin notes: written in Obsidian → committed to GitHub → auto-published with MkDocs Material.

## One-time setup (Windows)

1. Download the files from this bundle into a folder.
2. Open PowerShell in that folder and run:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\setup.ps1
   ```
   This clones the repo to `C:\Users\dvl\Documents\GitHub\dvl_notes`, copies in the scaffold,
   creates a Python venv, installs mkdocs-material + plugins, and pushes the first commit.
3. If you don't have GitHub CLI (`gh`) installed, do this **one manual step** the first time:
   GitHub repo → **Settings → Pages → Source → `gh-pages` branch**. (If `gh` is installed and
   authenticated, the script does this for you.)
4. Push — the `.github/workflows/deploy.yml` Action rebuilds and republishes the site automatically
   on every push to `main`. Nothing else to run by hand.

## Obsidian setup

1. Open Obsidian → **Open folder as vault** → select
   `C:\Users\dvl\Documents\GitHub\dvl_notes\docs`.
   (`docs/` is both your Obsidian vault root *and* the MkDocs source — one folder, no syncing needed.)
2. Settings → Files & Links:
   - **Attachment folder**: `assets` (keeps images/PDFs organized and matches `.gitignore`).
   - You can leave **Wikilinks** ([[Page]]) enabled — the `roamlinks` MkDocs plugin resolves
     these automatically at build time.
3. Just write notes as `.md` files in subfolders (e.g. `docs/san/brocade-zoning.md`). Navigation on
   the published site is generated automatically from the folder structure (via
   `awesome-pages` plugin) — no manual nav list to maintain.

## Daily workflow

```powershell
cd C:\Users\dvl\Documents\GitHub\dvl_notes
git add -A
git commit -m "notes: update SAN zoning doc"
git push
```

That's it — the push triggers the Action, which builds and deploys to
**https://ahbmx.github.io/dvl_notes/** within ~1 minute.

## Local preview before pushing

```powershell
.\.venv\Scripts\Activate.ps1
mkdocs serve
```

Then open `http://127.0.0.1:8000`.
