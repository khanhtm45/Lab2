# Journal Trend Analyzer — Documentation Hub

> **Premium Mobile Application · Flutter · Material Design 3 · OpenAlex API**

---

## Documentation Index

| # | File | Description |
|---|------|-------------|
| 00 | `00_README.md` | This index file |
| 01 | `01_SYSTEM_ARCHITECTURE.md` | Project structure, layers, data flow |
| 02 | `02_PROJECT_REQUIREMENTS.md` | Full feature requirements |
| 03 | `03_OPENALEX_API_MAPPING.md` | All API endpoints and parameters |
| 04 | `04_FEATURE_CHECKLIST.md` | Implementation checklist |
| 05 | `05_DESIGN_SYSTEM.md` | **Colors, typography, components, spacing** |
| 06 | `06_ALL_SCREENS.md` | **Complete screen-by-screen UI specification** |
| 07 | `07_OPENALEX_API.md` | OpenAlex API reference guide |
| 08 | `08_FIREBASE.md` | Firebase features specification |
| 09 | `09_ANALYTICS.md` | Analytics events and tracking |
| 10 | `10_DEVELOPER_GUIDE.md` | Build, run, test instructions |
| 11 | `11_UI_COMPONENTS.md` | Widget catalog and reusable components |
| 12 | `12_SCREENS_IMPLEMENTATION.md` | Screen-level Flutter code guidance |

---

## Application Overview

**Name:** Journal Trend Analyzer  
**Platform:** Flutter (Android + iOS)  
**Purpose:** Analyze scientific publications, journals, authors, institutions, keywords, and citation trends using the [OpenAlex API](https://openalex.org).  
**Data Source:** OpenAlex API only — no backend, no local database.  
**Auth:** (Planned) Google Sign-In via Firebase Authentication  

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x, Dart 3.11+ |
| State Management | Provider |
| Networking | `http` package |
| Charts | `fl_chart` |
| Fonts | `google_fonts` (Be Vietnam Pro / Inter) |
| Storage | `shared_preferences` |
| URL Launch | `url_launcher` |
| Firebase (planned) | Auth, Storage, Analytics, Crashlytics, Remote Config, FCM |

---

## Color Palette (Quick Reference)

| Role | Hex | Preview |
|------|-----|---------|
| Primary | `#2563EB` | Blue |
| Secondary | `#06B6D4` | Cyan |
| Accent | `#7C3AED` | Violet |
| Background | `#F8FAFC` | Off-white |
| Card | `#FFFFFF` | White |
| Success | `#22C55E` | Green |
| Warning | `#F59E0B` | Amber |
| Error | `#EF4444` | Red |
| Text Primary | `#0F172A` | Near-black |
| Text Secondary | `#64748B` | Slate |

---

## Navigation Structure

```
App
└── MainShell (Bottom Navigation — 4 tabs)
    ├── [0] Home      — Dashboard & discovery
    ├── [1] Journal   — Journal search & detail
    ├── [2] Trend     — Keyword trend analysis
    └── [3] Profile   — User profile, bookmarks, Firebase
```
