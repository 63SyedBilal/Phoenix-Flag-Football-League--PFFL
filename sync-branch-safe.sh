#!/bin/bash
# Safe Git Branch Sync Script (Bash version)
# This script safely syncs your local branch with remote changes

BRANCH_NAME="${1:-waqas5904}"
USE_REBASE="${2:-false}"

echo "=== Safe Git Branch Sync Workflow ==="
echo "Branch: $BRANCH_NAME"
echo ""

# Step 1: Check current status
echo "Step 1: Checking current status..."
git status

read -p "Continue with stashing? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Step 2: Stash local changes
echo ""
echo "Step 2: Stashing local changes..."
git stash push -u -m "WIP: Local changes before sync on $(date '+%Y-%m-%d %H:%M:%S')"

if [ $? -ne 0 ]; then
    echo "Error: Failed to stash changes"
    exit 1
fi

echo "✓ Changes stashed successfully"

# Step 3: Fetch remote changes
echo ""
echo "Step 3: Fetching remote changes..."
git fetch origin

if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch from remote"
    echo "Restoring stashed changes..."
    git stash pop
    exit 1
fi

echo "✓ Remote changes fetched"

# Step 4: Checkout branch
echo ""
echo "Step 4: Ensuring on correct branch..."
git checkout "$BRANCH_NAME"

if [ $? -ne 0 ]; then
    echo "Error: Failed to checkout branch"
    echo "Restoring stashed changes..."
    git stash pop
    exit 1
fi

# Step 5: Merge or Rebase
echo ""
if [ "$USE_REBASE" = "true" ]; then
    echo "Step 5: Rebasing with remote changes..."
    git rebase "origin/$BRANCH_NAME"
else
    echo "Step 5: Merging remote changes..."
    git merge "origin/$BRANCH_NAME"
fi

if [ $? -ne 0 ]; then
    echo ""
    echo "⚠️  CONFLICTS DETECTED!"
    echo "Please resolve conflicts manually, then:"
    if [ "$USE_REBASE" = "true" ]; then
        echo "  git add ."
        echo "  git rebase --continue"
    else
        echo "  git add ."
        echo "  git commit"
    fi
    echo ""
    echo "After resolving conflicts, run:"
    echo "  git stash pop"
    exit 1
fi

echo "✓ Remote changes integrated"

# Step 6: Apply stashed changes
echo ""
echo "Step 6: Applying stashed changes back..."
git stash pop

if [ $? -ne 0 ]; then
    echo ""
    echo "⚠️  CONFLICTS DETECTED when applying stash!"
    echo "Please resolve conflicts manually:"
    echo "  1. Edit conflicted files"
    echo "  2. git add <resolved-files>"
    echo "  3. git stash drop  (to remove stash entry)"
    exit 1
fi

echo "✓ Stashed changes applied"

# Step 7: Show final status
echo ""
echo "Step 7: Final status..."
git status

echo ""
echo "=== Sync Complete ==="
echo ""
echo "Next steps:"
echo "  1. Review your changes (git diff)"
echo "  2. Test your Flutter app (flutter run)"
echo "  3. Commit if needed (git add . && git commit -m 'message')"
echo "  4. Push to remote (git push origin $BRANCH_NAME)"
echo ""
