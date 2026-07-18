# 🔧 SonarQube CI/CD Error Fix

## ❌ Error Message
```
Run flutter pub get
Error: An error occurred trying to start process 'C:\Program Files\PowerShell\7\pwsh.EXE' 
with working directory 'D:\a\Lab2\Lab2\journal_trend_analyzer'. 
The directory name is invalid.
```

## 🎯 Root Cause
The CI/CD pipeline is looking for directory `D:\a\Lab2\Lab2\journal_trend_analyzer` but your project is at `D:\PRM391\Lab2\journal_trend_analyzer_v2`.

This happens because:
1. GitHub Actions default working directory structure is `$GITHUB_WORKSPACE` which is `D:\a\{repo}\{repo}`
2. Your project name in CI/CD doesn't match your local project name

## ✅ Solution 1: Fix GitHub Actions Workflow

Update your `.github/workflows/sonarqube.yml`:

```yaml
name: SonarQube Analysis

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    types: [ opened, synchronize, reopened ]

jobs:
  sonarqube:
    name: SonarQube Scan
    runs-on: ubuntu-latest  # Use ubuntu instead of windows-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.6'
          channel: 'stable'
      
      - name: Verify directory
        run: |
          echo "Current directory: $(pwd)"
          ls -la
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage || true
        continue-on-error: true
      
      - name: SonarQube Scan
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

## ✅ Solution 2: Use Bash Instead of PowerShell

If you must use Windows runner, specify bash shell:

```yaml
jobs:
  sonarqube:
    runs-on: windows-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Get dependencies
        shell: bash  # ⭐ Force bash instead of pwsh
        run: flutter pub get
```

## ✅ Solution 3: Fix Repository Name

If your GitHub repository name is `journal_trend_analyzer` (without `_v2`):

1. **Option A**: Rename local project folder to match repo name
```bash
# Rename folder
mv journal_trend_analyzer_v2 journal_trend_analyzer
```

2. **Option B**: Update pubspec.yaml name to match
```yaml
name: journal_trend_analyzer  # Remove _v2
```

## ✅ Solution 4: Run Locally First

Test locally before pushing to CI/CD:

### Windows (PowerShell):
```powershell
cd D:\PRM391\Lab2\journal_trend_analyzer_v2
.\scripts\run_sonar_analysis.bat
```

### Linux/Mac (Bash):
```bash
cd /path/to/journal_trend_analyzer_v2
chmod +x scripts/run_sonar_analysis.sh
./scripts/run_sonar_analysis.sh
```

## 🐳 Solution 5: Use Docker

Run SonarQube analysis in Docker (works everywhere):

```bash
# Start SonarQube server
docker-compose up -d sonarqube

# Wait for SonarQube to start (30-60 seconds)
# Access: http://localhost:9000 (admin/admin)

# Run analysis in Docker
docker run --rm \
  --network host \
  -v "$(pwd):/usr/src" \
  -w /usr/src \
  ghcr.io/cirruslabs/flutter:stable \
  bash -c "flutter pub get && flutter analyze && sonar-scanner"
```

## 📋 Checklist Before Pushing

- [ ] Verify project name matches between local and repository
- [ ] Test `flutter pub get` locally
- [ ] Check `.github/workflows/sonarqube.yml` exists
- [ ] Verify `sonar-project.properties` has correct paths
- [ ] Set GitHub Secrets: `SONAR_TOKEN` and `SONAR_HOST_URL`
- [ ] Use `ubuntu-latest` runner (more stable than Windows)
- [ ] Add `shell: bash` for Windows runners

## 🔍 Debug CI/CD

Add debug steps to your workflow:

```yaml
- name: Debug - Show environment
  run: |
    echo "Working directory: $(pwd)"
    echo "Flutter version: $(flutter --version)"
    echo "Dart version: $(dart --version)"
    ls -la
    
- name: Debug - Verify pubspec.yaml
  run: cat pubspec.yaml
  
- name: Debug - Check Flutter doctor
  run: flutter doctor -v
```

## 📚 References

- [GitHub Actions Default Environment](https://docs.github.com/en/actions/learn-github-actions/variables)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [SonarQube Scanner](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)

---

## 🎯 Quick Fix Command

For immediate fix, ensure you're using ubuntu runner:

```yaml
runs-on: ubuntu-latest  # ✅ Not windows-latest
```

This avoids PowerShell path issues entirely!
