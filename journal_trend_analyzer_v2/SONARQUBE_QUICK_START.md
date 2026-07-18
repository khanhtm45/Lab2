# 🚀 SonarQube Quick Start Guide

## ⚡ TL;DR - Fix Your Error NOW

Your error happens because CI/CD is looking for wrong directory. **Quick fix**:

### In `.github/workflows/sonarqube.yml`, change:
```yaml
runs-on: windows-latest  # ❌ REMOVE THIS
```

### To:
```yaml
runs-on: ubuntu-latest  # ✅ USE THIS
```

**That's it!** Ubuntu runner doesn't have PowerShell path issues.

---

## 📦 What Was Added to Your Project

```
journal_trend_analyzer_v2/
├── sonar-project.properties          ← SonarQube config
├── .github/workflows/sonarqube.yml   ← GitHub Actions workflow
├── docker-compose.yml                ← Updated with SonarQube service
├── scripts/
│   ├── run_sonar_analysis.bat        ← Windows script
│   └── run_sonar_analysis.sh         ← Linux/Mac script
├── SONARQUBE_SETUP.md                ← Full documentation
├── SONARQUBE_CI_FIX.md               ← Error troubleshooting
└── SONARQUBE_QUICK_START.md          ← This file
```

---

## 🎯 Option 1: Local Analysis (No Server Needed)

If you just want to run `flutter analyze` locally:

```bash
cd D:\PRM391\Lab2\journal_trend_analyzer_v2
flutter analyze
```

✅ **Done!** No SonarQube server needed for basic analysis.

---

## 🐳 Option 2: Full SonarQube with Docker (Recommended)

### Step 1: Start SonarQube Server
```bash
docker-compose up -d sonarqube
```

### Step 2: Access SonarQube
- URL: http://localhost:9000
- Login: `admin` / `admin`
- Change password when prompted

### Step 3: Create Project
1. Click "Create Project" → "Manually"
2. Project key: `journal_trend_analyzer_v2`
3. Generate token → Copy it

### Step 4: Run Analysis
```bash
# Windows
.\scripts\run_sonar_analysis.bat

# Linux/Mac
chmod +x scripts/run_sonar_analysis.sh
./scripts/run_sonar_analysis.sh
```

### Step 5: View Results
Open: http://localhost:9000/dashboard?id=journal_trend_analyzer_v2

✅ **Done!** Your code is analyzed.

---

## ☁️ Option 3: GitHub Actions (CI/CD)

### Step 1: Push Your Code
```bash
git add .
git commit -m "Add SonarQube configuration"
git push origin main
```

### Step 2: Add Secrets to GitHub
1. Go to: **Settings** → **Secrets and variables** → **Actions**
2. Add:
   - `SONAR_TOKEN`: Your token from Step 3 of Option 2
   - `SONAR_HOST_URL`: `http://your-server:9000`

### Step 3: Wait for Analysis
- GitHub Actions will automatically run on push
- Check: **Actions** tab in your repository

✅ **Done!** Automatic analysis on every push.

---

## 🔧 Troubleshooting

### Error: "Directory name is invalid"
**Fix**: Use `ubuntu-latest` runner instead of `windows-latest` in workflow.

### Error: "sonar-scanner not found"
**Fix Option 1**: Install via Chocolatey:
```bash
choco install sonarscanner
```

**Fix Option 2**: Use Docker (no installation needed):
```bash
docker-compose up -d sonarqube
```

### Error: "Flutter pub get failed"
**Fix**: Ensure Flutter is installed:
```bash
flutter doctor
flutter pub get
```

---

## 📊 What SonarQube Shows

1. **🐛 Bugs**: Potential runtime errors (e.g., null pointer exceptions)
2. **🔒 Vulnerabilities**: Security issues
3. **💩 Code Smells**: Maintainability issues (e.g., long methods, complex code)
4. **📋 Duplications**: Copy-pasted code that should be refactored
5. **✅ Coverage**: How much code is tested (if tests are run)

---

## 🎓 Best Practices

1. **Run locally before committing**:
   ```bash
   flutter analyze
   flutter test
   ```

2. **Fix critical issues first**: Bugs > Vulnerabilities > Code Smells

3. **Keep quality gate green**: Don't merge if SonarQube fails

4. **Review duplications**: Refactor repeated code

5. **Increase test coverage**: Aim for >80%

---

## 📚 Need More Info?

- **Full Setup Guide**: See `SONARQUBE_SETUP.md`
- **CI/CD Error Fixes**: See `SONARQUBE_CI_FIX.md`
- **SonarQube Docs**: https://docs.sonarqube.org/

---

## 💡 Pro Tips

### Exclude Files from Analysis
Edit `sonar-project.properties`:
```properties
sonar.exclusions=**/*.g.dart,**/*.freezed.dart,lib/generated/**
```

### Run Analysis on Specific Folder
```bash
sonar-scanner -Dsonar.sources=lib/screens
```

### View Coverage Report
```bash
flutter test --coverage
# Open: coverage/lcov.info
```

---

## ✅ Summary

| Task | Command | Time |
|------|---------|------|
| **Local Analysis** | `flutter analyze` | 10 sec |
| **Start SonarQube** | `docker-compose up -d` | 60 sec |
| **Full Analysis** | `.\scripts\run_sonar_analysis.bat` | 2 min |
| **View Results** | Open http://localhost:9000 | - |

**Recommendation**: Start with **Option 1** (local), then move to **Option 2** (Docker) for full features.

---

**Questions?** Check `SONARQUBE_SETUP.md` or `SONARQUBE_CI_FIX.md` for detailed troubleshooting! 🚀
