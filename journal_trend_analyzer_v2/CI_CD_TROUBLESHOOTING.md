# 🔧 CI/CD Troubleshooting Guide

## ❌ Error: "Directory name is invalid"

```
Error: An error occurred trying to start process 'C:\Program Files\PowerShell\7\pwsh.EXE' 
with working directory 'D:\a\Lab2\Lab2\journal_trend_analyzer'. 
The directory name is invalid.
```

### 🎯 Root Causes

1. **Repository name mismatch**: GitHub expects `journal_trend_analyzer` but project is `journal_trend_analyzer_v2`
2. **PowerShell path issues**: Windows runner with PowerShell has path resolution problems
3. **Working directory not set**: Workflow doesn't verify directory before running commands

### ✅ Solutions (Choose One)

---

## **Solution 1: Use Ubuntu Runner** (⭐ Recommended - Easiest)

Change workflow to use Ubuntu instead of Windows:

**File**: `.github/workflows/sonarqube.yml`

```yaml
jobs:
  sonarqube:
    runs-on: ubuntu-latest  # ✅ Change this line
    
    defaults:
      run:
        shell: bash  # ✅ Add this
```

**Why this works**: Ubuntu doesn't have PowerShell path issues and is more stable for CI/CD.

**Test it**:
```bash
git add .github/workflows/sonarqube.yml
git commit -m "Fix: Use ubuntu runner for SonarQube"
git push
```

---

## **Solution 2: Rename Project to Match Repository**

If your GitHub repository is named `Lab2`:

### Option A: Rename local folder
```bash
cd D:\PRM391\Lab2
mv journal_trend_analyzer_v2 journal_trend_analyzer
cd journal_trend_analyzer
```

### Option B: Update pubspec.yaml
```yaml
name: journal_trend_analyzer  # Remove _v2
```

Then commit:
```bash
git add pubspec.yaml
git commit -m "Fix: Match project name with repository"
git push
```

---

## **Solution 3: Use CMD Shell on Windows**

If you must use Windows runner:

```yaml
jobs:
  sonarqube:
    runs-on: windows-latest
    
    steps:
      - name: Get dependencies
        shell: cmd  # ✅ Use cmd instead of pwsh
        run: flutter pub get
      
      - name: Analyze code
        shell: cmd  # ✅ Use cmd instead of pwsh
        run: flutter analyze
```

---

## **Solution 4: Specify Working Directory**

Explicitly set the working directory in each step:

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v4
  
  - name: Debug - Show directory
    run: |
      echo "Current: $(pwd)"
      ls -la
  
  - name: Get dependencies
    working-directory: ${{ github.workspace }}  # ✅ Add this
    run: flutter pub get
```

---

## **Solution 5: Use Flutter Analyze Workflow Only**

Skip SonarQube entirely and just use Flutter's built-in analyzer:

**Use**: `.github/workflows/flutter-analyze.yml` (already created)

This workflow:
- ✅ Runs on Ubuntu (stable)
- ✅ Uses Flutter analyze
- ✅ Runs tests with coverage
- ✅ No SonarQube setup needed

```bash
# The flutter-analyze.yml workflow will run automatically
# Just push your code
git push
```

---

## 🐛 Common CI/CD Errors & Fixes

### Error: "Flutter not found"

```yaml
- name: Set up Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.44.6'  # ✅ Specify version
    channel: 'stable'
    cache: true  # ✅ Enable caching
```

### Error: "pub get failed - connection timeout"

```yaml
- name: Get dependencies
  run: flutter pub get
  timeout-minutes: 10  # ✅ Add timeout
  env:
    PUB_HOSTED_URL: https://pub.dev  # ✅ Explicit URL
```

### Error: "Permission denied"

```yaml
- name: Make script executable
  run: chmod +x scripts/*.sh  # ✅ For Linux/Mac scripts
```

### Error: "SonarQube token not found"

1. Go to: **Repository Settings** → **Secrets and variables** → **Actions**
2. Add secrets:
   - `SONAR_TOKEN`: Your token
   - `SONAR_HOST_URL`: Your server URL

### Error: "Coverage file not found"

```yaml
- name: Run tests
  run: flutter test --coverage  # ✅ Generates coverage/lcov.info
```

---

## 🧪 Test Workflows Locally

### Using Act (GitHub Actions locally)

```bash
# Install Act
choco install act

# Test workflow
act -j sonarqube

# Test with secrets
act -j sonarqube --secret SONAR_TOKEN=your-token
```

### Manual Testing

```bash
# Simulate CI/CD steps
cd D:\PRM391\Lab2\journal_trend_analyzer_v2

# Step 1: Clean
flutter clean

# Step 2: Get dependencies
flutter pub get

# Step 3: Analyze
flutter analyze

# Step 4: Test
flutter test --coverage

# Step 5: Check coverage
# Open: coverage/lcov.info
```

---

## 📋 Pre-Push Checklist

Before pushing to GitHub, verify locally:

- [ ] `flutter pub get` works
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Workflow file syntax is valid
- [ ] Repository name matches project name (or use ubuntu runner)
- [ ] Secrets are configured in GitHub

---

## 🔍 Debug CI/CD Pipeline

Add debug steps to your workflow:

```yaml
- name: Debug - Environment
  run: |
    echo "Runner OS: ${{ runner.os }}"
    echo "Workspace: ${{ github.workspace }}"
    echo "Repository: ${{ github.repository }}"
    echo "Current directory: $(pwd)"
    echo "Flutter version:"
    flutter --version
    echo "Dart version:"
    dart --version

- name: Debug - File structure
  run: |
    echo "Root files:"
    ls -la
    echo "Pubspec.yaml content:"
    cat pubspec.yaml
```

---

## 📊 Workflow Recommendations

### For Production:
✅ Use `ubuntu-latest` runner
✅ Enable caching for Flutter
✅ Run tests with coverage
✅ Use SonarQube for quality gates

### For Development:
✅ Use `flutter-analyze.yml` (simple)
✅ Enable on pull requests only
✅ Make tests optional (continue-on-error)

### For Both:
✅ Add debug steps
✅ Use timeouts
✅ Cache dependencies
✅ Test locally first

---

## 🚀 Quick Fix Commands

### Fix 1: Switch to Ubuntu
```bash
# Edit workflow
code .github/workflows/sonarqube.yml

# Change: runs-on: windows-latest
# To:     runs-on: ubuntu-latest

# Commit and push
git add .
git commit -m "Fix: Switch to ubuntu runner"
git push
```

### Fix 2: Use Flutter Analyze Only
```bash
# Disable SonarQube workflow
mv .github/workflows/sonarqube.yml .github/workflows/sonarqube.yml.disabled

# Enable Flutter analyze
git add .github/workflows/flutter-analyze.yml
git commit -m "Use flutter analyze workflow"
git push
```

### Fix 3: Test Locally
```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

---

## 📚 Resources

- [GitHub Actions - Flutter](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-flutter)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [SonarQube Scanner](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)

---

## ✅ Recommended Solution

**For fastest fix**:

1. Use Ubuntu runner (Solution 1)
2. Or use Flutter Analyze workflow only (Solution 5)
3. Test locally before pushing

**Choose**: Solution 1 or Solution 5 for immediate fix! 🚀
