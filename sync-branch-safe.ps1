# Safe Git Branch Sync Script
# This script safely syncs your local branch with remote changes

param(
    [Parameter(Mandatory=$false)]
    [string]$BranchName = "waqas5904",
    
    [Parameter(Mandatory=$false)]
    [switch]$UseRebase = $false
)

Write-Host "=== Safe Git Branch Sync Workflow ===" -ForegroundColor Cyan
Write-Host "Branch: $BranchName" -ForegroundColor Yellow
Write-Host ""

# Step 1: Check current status
Write-Host "Step 1: Checking current status..." -ForegroundColor Green
git status

Write-Host ""
$continue = Read-Host "Continue with stashing? (y/n)"
if ($continue -ne "y") {
    Write-Host "Aborted." -ForegroundColor Red
    exit
}

# Step 2: Stash local changes
Write-Host ""
Write-Host "Step 2: Stashing local changes..." -ForegroundColor Green
git stash push -u -m "WIP: Local changes before sync on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to stash changes" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Changes stashed successfully" -ForegroundColor Green

# Step 3: Fetch remote changes
Write-Host ""
Write-Host "Step 3: Fetching remote changes..." -ForegroundColor Green
git fetch origin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to fetch from remote" -ForegroundColor Red
    Write-Host "Restoring stashed changes..." -ForegroundColor Yellow
    git stash pop
    exit 1
}

Write-Host "✓ Remote changes fetched" -ForegroundColor Green

# Step 4: Checkout branch
Write-Host ""
Write-Host "Step 4: Ensuring on correct branch..." -ForegroundColor Green
git checkout $BranchName

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to checkout branch" -ForegroundColor Red
    Write-Host "Restoring stashed changes..." -ForegroundColor Yellow
    git stash pop
    exit 1
}

# Step 5: Merge or Rebase
Write-Host ""
if ($UseRebase) {
    Write-Host "Step 5: Rebasing with remote changes..." -ForegroundColor Green
    git rebase origin/$BranchName
} else {
    Write-Host "Step 5: Merging remote changes..." -ForegroundColor Green
    git merge origin/$BranchName
}

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "⚠️  CONFLICTS DETECTED!" -ForegroundColor Red
    Write-Host "Please resolve conflicts manually, then:" -ForegroundColor Yellow
    if ($UseRebase) {
        Write-Host "  git add ." -ForegroundColor Cyan
        Write-Host "  git rebase --continue" -ForegroundColor Cyan
    } else {
        Write-Host "  git add ." -ForegroundColor Cyan
        Write-Host "  git commit" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "After resolving conflicts, run:" -ForegroundColor Yellow
    Write-Host "  git stash pop" -ForegroundColor Cyan
    exit 1
}

Write-Host "✓ Remote changes integrated" -ForegroundColor Green

# Step 6: Apply stashed changes
Write-Host ""
Write-Host "Step 6: Applying stashed changes back..." -ForegroundColor Green
git stash pop

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "⚠️  CONFLICTS DETECTED when applying stash!" -ForegroundColor Red
    Write-Host "Please resolve conflicts manually:" -ForegroundColor Yellow
    Write-Host "  1. Edit conflicted files" -ForegroundColor Cyan
    Write-Host "  2. git add <resolved-files>" -ForegroundColor Cyan
    Write-Host "  3. git stash drop  (to remove stash entry)" -ForegroundColor Cyan
    exit 1
}

Write-Host "✓ Stashed changes applied" -ForegroundColor Green

# Step 7: Show final status
Write-Host ""
Write-Host "Step 7: Final status..." -ForegroundColor Green
git status

Write-Host ""
Write-Host "=== Sync Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review your changes (git diff)" -ForegroundColor Cyan
Write-Host "  2. Test your Flutter app (flutter run)" -ForegroundColor Cyan
Write-Host "  3. Commit if needed (git add . && git commit -m 'message')" -ForegroundColor Cyan
Write-Host "  4. Push to remote (git push origin $BranchName)" -ForegroundColor Cyan
Write-Host ""

