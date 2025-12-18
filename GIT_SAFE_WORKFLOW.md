# Safe Git Workflow for Flutter Project

This guide provides a step-by-step workflow to safely sync your local branch with remote changes while preserving your local work.

## Prerequisites

- Current branch: `waqas5904` (or your branch name)
- Local changes exist that you want to preserve
- Remote branch may have new commits

---

## Step-by-Step Command Sequence

### Step 1: Check Current Status
First, see what changes you have locally:

```bash
git status
```

This shows:
- Modified files
- Untracked files
- Branch status

---

### Step 2: Stash Your Local Changes
Save your local changes temporarily:

```bash
git stash push -m "WIP: Local changes before sync"
```

**Optional: Include untracked files** (if you have new files):
```bash
git stash push -u -m "WIP: Local changes including untracked files"
```

**Verify stash was created:**
```bash
git stash list
```

---

### Step 3: Fetch Latest Remote Changes
Get the latest changes from remote **without** merging:

```bash
git fetch origin
```

**Check remote branch status:**
```bash
git log HEAD..origin/waqas5904 --oneline
```

This shows commits on remote that you don't have locally.

---

### Step 4: Checkout Your Branch (if not already on it)
```bash
git checkout waqas5904
```

---

### Step 5: Integrate Remote Changes

You have two options: **Merge** (safer, preserves history) or **Rebase** (cleaner history).

#### Option A: Merge (Recommended for safety)
```bash
git merge origin/waqas5904
```

#### Option B: Rebase (Creates linear history)
```bash
git rebase origin/waqas5904
```

**If conflicts occur during merge/rebase:**
- Git will pause and show conflict markers
- Resolve conflicts manually in affected files
- Then continue:

```bash
# After resolving conflicts for merge:
git add .
git commit

# After resolving conflicts for rebase:
git add .
git rebase --continue
```

---

### Step 6: Apply Your Stashed Changes Back
Restore your local changes:

```bash
git stash pop
```

**Alternative:** If you want to keep the stash (for safety):
```bash
git stash apply stash@{0}
# Later, if everything works, remove stash:
git stash drop stash@{0}
```

---

### Step 7: Resolve Any Conflicts from Stash
If `git stash pop` shows conflicts:

1. **Check conflicted files:**
   ```bash
   git status
   ```

2. **Open conflicted files** and look for conflict markers:
   ```
   <<<<<<< Updated upstream
   (remote changes)
   =======
   (your stashed changes)
   >>>>>>> Stashed changes
   ```

3. **Resolve conflicts** by editing files to keep the desired code

4. **Mark conflicts as resolved:**
   ```bash
   git add <resolved-file>
   ```

5. **If all conflicts resolved, clean up:**
   ```bash
   git stash drop  # Remove the stash entry
   ```

---

### Step 8: Verify Everything Works
Before pushing, make sure everything is correct:

```bash
# Check status
git status

# Review your changes
git diff HEAD~1

# Test your Flutter app
flutter run
# or
flutter test
```

---

### Step 9: Commit Your Stashed Changes (if not already committed)
If your stashed changes need to be committed:

```bash
git add .
git commit -m "Your commit message describing the changes"
```

---

### Step 10: Push to Remote
Only push after confirming everything works:

```bash
git push origin waqas5904
```

If remote has moved ahead (shouldn't happen after merge/rebase), use:

```bash
git push origin waqas5904 --force-with-lease
```

**⚠️ Warning:** Only use `--force-with-lease` if you're absolutely sure. It's safer than `--force` but still overwrites remote history.

---

## Complete Command Sequence (Copy-Paste Ready)

```bash
# 1. Check status
git status

# 2. Stash local changes
git stash push -u -m "WIP: Local changes before sync"

# 3. Fetch remote changes
git fetch origin

# 4. Ensure on correct branch
git checkout waqas5904

# 5. Merge remote changes (or use 'git rebase origin/waqas5904')
git merge origin/waqas5904

# 6. Apply stashed changes back
git stash pop

# 7. If conflicts appear, resolve them manually, then:
#    git add <resolved-files>
#    git stash drop  # if using stash pop

# 8. Verify everything works (test your app)

# 9. Commit if needed
git add .
git commit -m "Your commit message"

# 10. Push to remote
git push origin waqas5904
```

---

## Troubleshooting

### If you want to abort a merge:
```bash
git merge --abort
```

### If you want to abort a rebase:
```bash
git rebase --abort
```

### If you want to see your stash content:
```bash
git stash show -p stash@{0}
```

### If you want to create a backup branch before starting:
```bash
git branch waqas5904-backup
```

### If something goes wrong, restore from stash:
```bash
# See all stashes
git stash list

# Apply specific stash
git stash apply stash@{0}

# If stash pop failed, your changes are still in stash
git stash list  # Verify
```

---

## Safety Tips

1. **Always create a backup branch** before major operations:
   ```bash
   git branch waqas5904-backup
   ```

2. **Use `--force-with-lease` instead of `--force`** if you must force push:
   ```bash
   git push origin waqas5904 --force-with-lease
   ```

3. **Review changes before pushing:**
   ```bash
   git log origin/waqas5904..HEAD --oneline
   ```

4. **Keep stashes named** for easier identification:
   ```bash
   git stash push -m "Feature: Add payment screen"
   ```

5. **Test your app** after applying stash to ensure nothing broke

---

## Quick Reference Card

| Action | Command |
|--------|---------|
| Save local changes | `git stash push -u -m "message"` |
| List stashes | `git stash list` |
| Apply stash | `git stash pop` (removes stash) or `git stash apply` (keeps stash) |
| Fetch remote | `git fetch origin` |
| Merge remote | `git merge origin/branch-name` |
| Rebase remote | `git rebase origin/branch-name` |
| View conflicts | `git status` |
| Abort merge | `git merge --abort` |
| Abort rebase | `git rebase --abort` |
| Push changes | `git push origin branch-name` |

---

## Best Practices

1. ✅ **Commit frequently** - Small, logical commits are easier to merge
2. ✅ **Pull/merge regularly** - Don't let branches diverge too much
3. ✅ **Use feature branches** - Keep main/master stable
4. ✅ **Test before pushing** - Always verify your code works
5. ✅ **Write descriptive commit messages** - Help future you and your team
6. ✅ **Review your changes** - Use `git diff` before committing
