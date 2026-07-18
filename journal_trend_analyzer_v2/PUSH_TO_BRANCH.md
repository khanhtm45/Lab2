# 🚀 Push Code to New Branch - Quick Guide

## 🎯 **Easiest Way: Use Script**

### Windows:
```bash
.\scripts\git_push_branch.bat
```

### Linux/Mac:
```bash
chmod +x scripts/git_push_branch.sh
./scripts/git_push_branch.sh
```

**The script will:**
1. ✅ Ask for branch name
2. ✅ Create and switch to new branch
3. ✅ Show changes to be committed
4. ✅ Ask for commit message
5. ✅ Commit and push to new branch
6. ✅ Show instructions for creating Pull Request

---

## 📝 **Manual Method**

### **Quick (3 commands):**
```bash
git checkout -b feature/your-branch-name
git add .
git commit -m "feat: Your commit message"
git push -u origin feature/your-branch-name
```

### **Detailed Steps:**

#### 1. Create new branch
```bash
# Format: feature/name, fix/name, update/name
git checkout -b feature/sonarqube-setup
```

#### 2. Check what will be committed
```bash
git status
```

#### 3. Add all changes
```bash
git add .
```

#### 4. Commit with message
```bash
git commit -m "feat: Add SonarQube CI/CD configuration"
```

#### 5. Push to new branch
```bash
git push -u origin feature/sonarqube-setup
```

#### 6. Create Pull Request
- Go to: https://github.com/your-username/your-repo
- Click: **"Compare & pull request"** button
- Fill in PR details
- Click: **"Create pull request"**

---

## 🌿 **Recommended Branch Names**

### For this current work:
```bash
# All changes (SonarQube + Mock Data + Fixes)
git checkout -b feature/lab03-improvements

# Or separate branches
git checkout -b feature/sonarqube-cicd
git checkout -b feature/firebase-mock-data
git checkout -b fix/overflow-errors
```

### General patterns:
```bash
# New features
git checkout -b feature/new-feature-name

# Bug fixes
git checkout -b fix/bug-description

# Updates/Enhancements
git checkout -b update/what-you-updated

# Documentation
git checkout -b docs/documentation-update
```

---

## 💡 **Example for Current Changes**

```bash
# Create branch
git checkout -b feature/lab03-improvements

# Add everything
git add .

# Commit with detailed message
git commit -m "feat: Add Lab 03 improvements (SonarQube + Firebase Mock)

- Add SonarQube CI/CD workflows (3 options)
- Fix CI/CD PowerShell directory error
- Add Firebase mock data implementation
- Add interactive Firebase feature dialogs
- Fix keyword analysis overflow errors
- Add comprehensive documentation (10+ files)"

# Push to new branch
git push -u origin feature/lab03-improvements
```

---

## ✅ **Verification Checklist**

Before pushing, verify:

- [ ] Code compiles: `flutter analyze`
- [ ] Tests pass: `flutter test`
- [ ] No sensitive data (tokens, passwords)
- [ ] Commit message is descriptive
- [ ] Branch name follows convention

```bash
# Quick check
flutter analyze
flutter test
git status
```

---

## 🔄 **After Pushing**

### **Create Pull Request:**
1. Go to GitHub repository
2. You'll see: **"Compare & pull request"** banner
3. Click it
4. Fill in:
   - **Title**: Short summary (e.g., "feat: Add SonarQube CI/CD")
   - **Description**: What changed and why
5. Click: **"Create pull request"**

### **Pull Request Template:**
```markdown
## Summary
Add SonarQube CI/CD configuration and Firebase mock data

## Changes
- SonarQube workflows (Ubuntu, Windows, Simple)
- Firebase mock data in ProfileViewModel
- Fix CI/CD PowerShell errors
- Add comprehensive documentation

## Testing
- [x] Code compiles without errors
- [x] Flutter analyze passes
- [x] Mock data tested locally

## Screenshots
(Add if applicable)
```

---

## 🚫 **What NOT to Do**

### ❌ **DON'T push directly to main:**
```bash
git push origin main  # Bad - no review!
```

### ✅ **DO push to feature branch:**
```bash
git push origin feature/my-change  # Good - creates PR!
```

---

## 📚 **More Info**

- **Full guide**: See `GIT_WORKFLOW_GUIDE.md`
- **Git basics**: https://git-scm.com/book/en/v2

---

## 🎯 **TL;DR - Do This Now**

```bash
# Option 1: Use script (easiest)
.\scripts\git_push_branch.bat

# Option 2: Manual (3 commands)
git checkout -b feature/lab03-improvements
git add .
git commit -m "feat: Add Lab 03 improvements"
git push -u origin feature/lab03-improvements

# Then: Go to GitHub and create Pull Request
```

---

**That's it!** 🚀 Your code is now on a new branch ready for review!
