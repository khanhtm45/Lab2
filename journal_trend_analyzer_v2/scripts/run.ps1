# Journal Trend Analyzer V2 — always run THIS project (4 tabs, not JournalAI).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host ""
Write-Host "=== Journal Trend Analyzer V2 ===" -ForegroundColor Cyan
Write-Host "Folder: $Root" -ForegroundColor DarkGray
Write-Host "Expected UI: 4 tabs (Home, Journal, Analysis, Profile)" -ForegroundColor DarkGray
Write-Host ""

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (Test-Path $adb) {
  Write-Host "Removing old JournalAI package (com.example.lab2)..." -ForegroundColor Yellow
  & $adb uninstall com.example.lab2 2>$null | Out-Null
}

$DefinesFile = Join-Path $Root "dart_defines.local.json"

if (Test-Path $DefinesFile) {
  Write-Host "Using API key from dart_defines.local.json" -ForegroundColor Cyan
  flutter run --dart-define-from-file=dart_defines.local.json @args
} else {
  flutter run @args
}
