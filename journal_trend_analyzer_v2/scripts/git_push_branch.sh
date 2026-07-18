#!/bin/bash
# ========================================
# Git Push to New Branch Script
# ========================================

set -e

echo ""
echo "========================================"
echo "Git Push to New Branch"
echo "========================================"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "ERROR: Not a git repository"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"
echo ""

# Ask for new branch name
read -p "Enter new branch name (e.g., feature/sonarqube-setup): " BRANCH_NAME

if [ -z "$BRANCH_NAME" ]; then
    echo "ERROR: Branch name cannot be empty"
    exit 1
fi

echo ""
echo "========================================"
echo "Creating and switching to branch: $BRANCH_NAME"
echo "========================================"
git checkout -b "$BRANCH_NAME"

echo ""
echo "========================================"
echo "Checking git status..."
echo "========================================"
git status

echo ""
echo "========================================"
echo "Adding all changes..."
echo "========================================"
git add .

echo ""
echo "========================================"
echo "Current changes to be committed:"
echo "========================================"
git status --short

echo ""
read -p "Do you want to continue with commit? (y/n): " CONTINUE
if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
    echo "Aborted by user"
    exit 0
fi

echo ""
read -p "Enter commit message (e.g., feat: Add SonarQube configuration): " COMMIT_MESSAGE

if [ -z "$COMMIT_MESSAGE" ]; then
    COMMIT_MESSAGE="feat: Update project files"
    echo "Using default message: $COMMIT_MESSAGE"
fi

echo ""
echo "========================================"
echo "Committing changes..."
echo "========================================"
git commit -m "$COMMIT_MESSAGE"

echo ""
echo "========================================"
echo "Pushing to remote branch: $BRANCH_NAME"
echo "========================================"
git push -u origin "$BRANCH_NAME"

echo ""
echo "========================================"
echo "SUCCESS!"
echo "========================================"
echo ""
echo "Branch created: $BRANCH_NAME"
echo "Changes committed and pushed!"
echo ""
echo "Next steps:"
echo "1. Go to GitHub repository"
echo "2. Click 'Compare & pull request' button"
echo "3. Review changes and create Pull Request"
echo ""
echo "GitHub URL: https://github.com/your-username/your-repo"
echo ""
