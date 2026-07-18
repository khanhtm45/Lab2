# 🚀 CI/CD Quick Guide

## ❌ Got This Error?
```
Error: Directory 'D:\a\Lab2\Lab2\journal_trend_analyzer' is invalid
```

## ✅ **FIXED!** - Just push your code

```bash
git add .
git commit -m "Update CI/CD"
git push
```

Your CI/CD is now configured to run on **Ubuntu** (no more PowerShell errors)!

---

## 📁 What's Available

### **3 Workflow Options:**

1. **`sonarqube.yml`** ⭐ - Full SonarQube analysis (Ubuntu)
2. **`sonarqube-windows.yml`** - Windows alternative  
3. **`flutter-analyze.yml`** 🎯 **RECOMMENDED** - Simple Flutter analyze (no setup needed)

### **Documentation:**
- `CI_CD_FIXED_SUMMARY.md` - What was fixed
- `CI_CD_TROUBLESHOOTING.md` - If issues arise
- `SONARQUBE_QUICK_START.md` - SonarQube setup

---

## 🎯 Recommended: Use Flutter Analyze

The **simplest option** - No SonarQube server needed!

**File**: `.github/workflows/flutter-analyze.yml`

**What it does**:
- ✅ Runs `flutter analyze`
- ✅ Runs `flutter test --coverage`
- ✅ Checks code formatting
- ✅ Uploads coverage to Codecov (optional)

**Just push** and it works! No secrets, no server, no setup.

---

## 🔧 Need SonarQube?

### Quick Setup:
```bash
# Start SonarQube locally
docker-compose up -d sonarqube

# Access: http://localhost:9000 (admin/admin)
# Create project → Get token

# Add to GitHub:
# Settings → Secrets → Add:
#   SONAR_TOKEN = your_token
#   SONAR_HOST_URL = http://your-server:9000
```

---

## 🧪 Test Locally

```bash
# Clean + analyze
flutter clean
flutter pub get
flutter analyze
flutter test

# Or use script
.\scripts\run_sonar_analysis.bat  # Windows
./scripts/run_sonar_analysis.sh   # Linux/Mac
```

---

## 📊 View Results

### GitHub Actions:
Go to: **Actions** tab → See workflow results

### SonarQube:
Go to: http://localhost:9000 → Dashboard

---

## 💡 Pro Tip

**Start simple**: Use `flutter-analyze.yml` first, add SonarQube later if needed!

---

**Questions?** Read `CI_CD_FIXED_SUMMARY.md` for details! 🚀
