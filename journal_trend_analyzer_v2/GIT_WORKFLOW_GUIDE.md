# 🌿 Git Workflow Guide - Working with Branches

## 📋 Recommended Git Workflow

### **Option 1: Feature Branch Workflow** (Recommended ⭐)

```bash
# 1. Make sure you're on main/master
git checkout main
git pull origin main

# 2. Create new branch for your changes
git checkout -b feature/sonarqube-setup
# Or: git checkout -b fix/ci-cd-error
# Or: git checkout -b update/firebase-mock-data

# 3. Check current branch
git branch
# Should show: * feature/sonarqube-setup

# 4. Add your changes
git add .

# 5. Commit with descriptive message
git commit -m "feat: Add SonarQube CI/CD configuration

- Add sonarqube.yml workflow with Ubuntu runner
- Add flutter-analyze.yml for simple analysis
- Add Docker Compose with SonarQube service
- Add comprehensive documentation
- Fix PowerShell directory error in CI/CD"

# 6. Push to new branch
git push origin feature/sonarqube-setup

# 7. Create Pull Request on GitHub
# Go to: https://github.com/your-username/your-repo
# Click: "Compare & pull request"
```

---

## 🚀 Quick Commands

### **Create and Push to New Branch:**

```bash
# One-liner to create branch and switch to it
git checkout -b feature/my-new-feature

# Add all changes
git add .

# Commit
git commit -m "feat: Add new feature"

# Push to new branch (first time)
git push -u origin feature/my-new-feature

# Push subsequent changes (after first push)
git push
```

---

### **Different Branch Naming Conventions:**

```bash
# Feature branches
git checkout -b feature/sonarqube-setup
git checkout -b feature/firebase-mock-data
git checkout -b feature/keyword-analysis-charts

# Bug fix branches
git checkout -b fix/ci-cd-error
git checkout -b fix/overflow-keyword-screen
git checkout -b fix/journal-screen-bug

# Update/Enhancement branches
git checkout -b update/dependencies
git checkout -b update/documentation
git checkout -b enhance/profile-screen

# Hotfix branches (urgent fixes)
git checkout -b hotfix/critical-bug
```

---

## 📝 Commit Message Conventions

### **Format:**
```
<type>: <subject>

[optional body]

[optional footer]
```

### **Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### **Examples:**

```bash
# Good commit messages
git commit -m "feat: Add SonarQube configuration"
git commit -m "fix: Resolve CI/CD PowerShell error"
git commit -m "docs: Update setup documentation"
git commit -m "refactor: Simplify profile screen code"

# With body
git commit -m "feat: Add Firebase mock data

- Add mock Remote Config data
- Add mock Storage file list
- Add mock file upload simulation
- Update ProfileViewModel with fallback logic"
```

---

## 🔄 Complete Workflow Example

### **Scenario: Add SonarQube + Fix Mock Data**

```bash
# Step 1: Start from main
cd D:\PRM391\Lab2\journal_trend_analyzer_v2
git checkout main
git pull origin main

# Step 2: Create feature branch
git checkout -b feature/sonarqube-and-mock-data

# Step 3: Check status
git status
# Should show all your new/modified files

# Step 4: Add specific files (or all)
git add .github/
git add sonar-project.properties
git add docker-compose.yml
git add scripts/
git add *.md
git add lib/viewmodels/profile_viewmodel.dart
git add lib/screens/profile_screen.dart

# Or add everything
git add .

# Step 5: Commit
git commit -m "feat: Add SonarQube CI/CD and Firebase mock data

CI/CD Improvements:
- Add sonarqube.yml workflow with Ubuntu runner
- Add flutter-analyze.yml for simple analysis
- Add sonarqube-windows.yml as Windows alternative
- Fix PowerShell directory error
- Add debug steps for troubleshooting

Firebase Mock Data:
- Add mock Remote Config with 8 config values
- Add mock uploaded files list
- Add mockSelectFile() and mockUploadFile() methods
- Add interactive dialogs for Firebase features
- Show success messages with proper icons

Documentation:
- Add SONARQUBE_SETUP.md
- Add SONARQUBE_QUICK_START.md
- Add CI_CD_TROUBLESHOOTING.md
- Add CI_CD_FIXED_SUMMARY.md
- Add GIT_WORKFLOW_GUIDE.md

Fixes:
- Fix keyword analysis screen overflow (5px)
- Fix profile screen Firebase feature dialogs
- Update docker-compose.yml with SonarQube service"

# Step 6: Push to remote
git push -u origin feature/sonarqube-and-mock-data

# Step 7: Create Pull Request
# Go to GitHub → Your repo → "Compare & pull request" button
```

---

## 🌳 Branch Management

### **List Branches:**
```bash
# List local branches
git branch

# List remote branches
git branch -r

# List all branches
git branch -a
```

### **Switch Branches:**
```bash
# Switch to existing branch
git checkout main
git checkout feature/my-feature

# Create and switch to new branch
git checkout -b feature/new-feature
```

### **Delete Branches:**
```bash
# Delete local branch (after merged)
git branch -d feature/old-feature

# Force delete local branch
git branch -D feature/old-feature

# Delete remote branch
git push origin --delete feature/old-feature
```

### **Update Branch from Main:**
```bash
# While on feature branch
git checkout feature/my-feature
git merge main

# Or using rebase (cleaner history)
git checkout feature/my-feature
git rebase main
```

---

## 🎯 Workflow for This Project

### **Current Changes: SonarQube + Mock Data**

```bash
# 1. Create branch
git checkout -b feature/lab03-improvements

# 2. Stage all changes
git add .

# 3. Commit with detailed message
git commit -m "feat: Add Lab 03 improvements

SonarQube CI/CD:
- Configure Ubuntu runner to fix PowerShell errors
- Add 3 workflow options (SonarQube, Windows, Simple)
- Add Docker Compose with SonarQube service
- Add automation scripts for Windows and Linux
- Add comprehensive documentation (6 files)

Firebase Mock Data:
- Add mock data for Remote Config (8 values)
- Add mock uploaded files list (3 files)
- Implement mock file selection and upload
- Add interactive dialogs for all Firebase features
- Show success/error messages with proper UX

UI Fixes:
- Fix keyword analysis overflow (Column: 5px)
- Fix profile screen Firebase feature interactions
- Add Analytics, Storage, Messaging, Remote Config dialogs
- Improve user feedback with snackbars and icons

Documentation:
- SONARQUBE_SETUP.md - Full setup guide
- SONARQUBE_QUICK_START.md - Quick reference
- CI_CD_TROUBLESHOOTING.md - Error fixes
- CI_CD_FIXED_SUMMARY.md - Summary
- GIT_WORKFLOW_GUIDE.md - This file
- README_CI_CD.md - Quick start

Testing:
- All files compile without errors
- Workflows validated
- Mock data tested locally"

# 4. Push to new branch
git push -u origin feature/lab03-improvements

# 5. Go to GitHub and create Pull Request
```

---

## 📊 Pull Request Best Practices

### **PR Title:**
```
feat: Add Lab 03 improvements (SonarQube + Firebase Mock)
```

### **PR Description Template:**
```markdown
## 📋 Summary
Add SonarQube CI/CD configuration and Firebase mock data implementation

## 🎯 Changes
- [ ] SonarQube CI/CD workflows (3 options)
- [ ] Firebase mock data in ProfileViewModel
- [ ] Interactive Firebase feature dialogs
- [ ] Fix CI/CD PowerShell errors
- [ ] Comprehensive documentation
- [ ] UI overflow fixes

## 🧪 Testing
- [x] Code compiles without errors
- [x] Flutter analyze passes
- [x] Workflows syntax validated
- [x] Mock data tested locally
- [x] Dialogs display correctly

## 📚 Documentation
- Added 6 new documentation files
- Updated docker-compose.yml
- Added automation scripts

## 🔗 Related Issues
Fixes #123 (if applicable)

## 📸 Screenshots
(Add screenshots of new dialogs if needed)
```

---

## 🔍 Check Before Pushing

```bash
# Check what will be committed
git status

# Check differences
git diff

# Check differences for staged files
git diff --staged

# View commit history
git log --oneline -5

# View branch graph
git log --graph --oneline --all -10
```

---

## ⚠️ Common Mistakes to Avoid

### **DON'T:**
❌ Push directly to `main` without review
```bash
git push origin main  # Bad practice
```

### **DO:**
✅ Create feature branch and PR
```bash
git checkout -b feature/my-change
git push origin feature/my-change  # Good practice
```

### **DON'T:**
❌ Commit everything with vague message
```bash
git commit -m "updates"  # Bad
```

### **DO:**
✅ Write descriptive commit messages
```bash
git commit -m "feat: Add SonarQube configuration"  # Good
```

---

## 🚀 Quick Reference Card

```bash
# Create branch and push
git checkout -b feature/my-feature
git add .
git commit -m "feat: Description"
git push -u origin feature/my-feature

# Update branch from main
git checkout main
git pull
git checkout feature/my-feature
git merge main

# Delete branch after merge
git branch -d feature/my-feature
git push origin --delete feature/my-feature

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Stash changes temporarily
git stash
git stash pop
```

---

## 📚 Resources

- [Git Branching Strategy](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Pull Requests](https://docs.github.com/en/pull-requests)

---

## ✅ Summary

**For this project, run:**

```bash
git checkout -b feature/lab03-improvements
git add .
git commit -m "feat: Add Lab 03 improvements (SonarQube + Firebase Mock)"
git push -u origin feature/lab03-improvements
```

Then create Pull Request on GitHub! 🚀
