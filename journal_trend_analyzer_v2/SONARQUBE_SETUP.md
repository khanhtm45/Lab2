# SonarQube Setup Guide

## 📋 Prerequisites

1. **SonarQube Server** (local or cloud)
2. **SonarQube Scanner** installed locally or in CI/CD
3. **Flutter SDK** installed

## 🔧 Local Setup

### 1. Install SonarQube Scanner

#### Windows (using Chocolatey):
```bash
choco install sonarscanner
```

#### Manual Installation:
1. Download from: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
2. Extract and add to PATH

### 2. Run SonarQube Analysis Locally

```bash
# Navigate to project directory
cd d:\PRM391\Lab2\journal_trend_analyzer_v2

# Get Flutter dependencies
flutter pub get

# Run Flutter analyze
flutter analyze

# Optional: Run tests with coverage
flutter test --coverage

# Run SonarQube Scanner
sonar-scanner \
  -Dsonar.projectKey=journal_trend_analyzer_v2 \
  -Dsonar.sources=lib \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=YOUR_SONAR_TOKEN
```

## 🐳 Docker Setup (Recommended)

### 1. Start SonarQube with Docker

```bash
docker-compose up -d sonarqube
```

### 2. Access SonarQube
- URL: http://localhost:9000
- Default credentials:
  - Username: `admin`
  - Password: `admin`

### 3. Create Project
1. Click "Create Project" → "Manually"
2. Project key: `journal_trend_analyzer_v2`
3. Display name: `Journal Trend Analyzer V2`
4. Generate token and save it

### 4. Run Analysis

```bash
# Set environment variables
export SONAR_TOKEN=your_generated_token
export SONAR_HOST_URL=http://localhost:9000

# Run scanner
sonar-scanner
```

## 🚀 CI/CD Setup (GitHub Actions)

The project includes `.github/workflows/sonarqube.yml` for automated analysis.

### Required GitHub Secrets:
1. Go to: Settings → Secrets and variables → Actions
2. Add secrets:
   - `SONAR_TOKEN`: Your SonarQube token
   - `SONAR_HOST_URL`: Your SonarQube server URL (e.g., `http://localhost:9000` or `https://sonarcloud.io`)

### Trigger Analysis:
- Push to `main`, `master`, or `develop` branches
- Open or update Pull Requests

## 📊 SonarQube Configuration

The `sonar-project.properties` file includes:

- **Sources**: `lib/` (main application code)
- **Tests**: `test/`, `integration_test/`
- **Exclusions**: Generated files, build artifacts, platform-specific code
- **Language**: Dart
- **Encoding**: UTF-8

## 🔍 Common Issues

### Issue 1: "Directory name is invalid"
**Solution**: Ensure you're in the correct project directory:
```bash
cd d:\PRM391\Lab2\journal_trend_analyzer_v2
pwd  # Verify correct path
```

### Issue 2: "sonar-scanner not found"
**Solution**: Add sonar-scanner to PATH or use full path:
```bash
C:\sonar-scanner\bin\sonar-scanner.bat
```

### Issue 3: PowerShell execution error
**Solution**: Use CMD or Git Bash instead:
```bash
# In CMD
sonar-scanner.bat

# Or specify shell in CI/CD
shell: bash
```

### Issue 4: Flutter pub get fails
**Solution**: Ensure Flutter is installed and in PATH:
```bash
flutter doctor
flutter pub get
```

## 📈 What SonarQube Analyzes

1. **Code Smells**: Maintainability issues
2. **Bugs**: Potential runtime errors
3. **Vulnerabilities**: Security issues
4. **Duplications**: Code duplication
5. **Coverage**: Test coverage (if configured)
6. **Complexity**: Cyclomatic complexity

## 🎯 Best Practices

1. **Fix issues before merging**: Address critical bugs and vulnerabilities
2. **Monitor code smells**: Keep technical debt under control
3. **Maintain test coverage**: Aim for >80% coverage
4. **Review duplications**: Refactor duplicate code
5. **Use quality gates**: Block merges that don't meet quality standards

## 📚 Additional Resources

- [SonarQube Documentation](https://docs.sonarqube.org/)
- [SonarQube for Flutter](https://community.sonarsource.com/t/flutter-dart-support/)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)

## 🛠️ Quick Commands

```bash
# Full analysis workflow
flutter clean
flutter pub get
flutter analyze
flutter test --coverage
sonar-scanner

# View results
# Open: http://localhost:9000/dashboard?id=journal_trend_analyzer_v2
```

## ⚙️ Docker Compose Configuration

The project includes a `docker-compose.yml` with SonarQube service configuration.

```bash
# Start SonarQube
docker-compose up -d sonarqube

# Stop SonarQube
docker-compose down

# View logs
docker-compose logs -f sonarqube
```

---

**Note**: For production environments, configure SonarQube with proper authentication, SSL, and database backend.
