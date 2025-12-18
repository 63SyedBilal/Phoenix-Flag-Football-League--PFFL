# Quick Git Sync Commands

Copy-paste these commands one by one, or use the provided scripts.

## Manual Command Sequence

```powershell
# 1. Check what you have
git status

# 2. Save your changes safely
git stash push -u -m "WIP: My local changes"

# 3. Get latest from remote (doesn't merge yet)
git fetch origin

# 4. Make sure you're on your branch
git checkout waqas5904

# 5. Merge remote changes (safer) OR rebase (cleaner)
git merge origin/waqas5904
# OR
git rebase origin/waqas5904

# 6. Get your changes back
git stash pop

# 7. If conflicts appear, resolve them manually, then:
#    git add <resolved-files>
#    git stash drop  # if using stash pop

# 8. Test your app
flutter run

# 9. Commit if needed
git add .
git commit -m "Your commit message"

# 10. Push to remote
git push origin waqas5904
```

## Using the PowerShell Script

```powershell
# Make script executable (first time only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the script
.\sync-branch-safe.ps1 -BranchName waqas5904

# Or with rebase instead of merge
.\sync-branch-safe.ps1 -BranchName waqas5904 -UseRebase
```

## Using the Bash Script (Git Bash / Linux / Mac)

```bash
# Make script executable (first time only)
chmod +x sync-branch-safe.sh

# Run the script
./sync-branch-safe.sh waqas5904

# Or with rebase
./sync-branch-safe.sh waqas5904 true
```

## If Something Goes Wrong

### Abort merge/rebase:
```bash
git merge --abort    # if merging
git rebase --abort   # if rebasing
```

### Get your stashed changes back:
```bash
git stash list              # see all stashes
git stash apply stash@{0}   # apply without removing
git stash pop              # apply and remove
```

### Create backup branch first (recommended):
```bash
git branch waqas5904-backup
# Now you can always go back: git checkout waqas5904-backup
```
