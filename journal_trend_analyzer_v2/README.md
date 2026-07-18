# Journal Trend Analyzer v2 — PRM393 Lab 2

App Flutter phân tích xu hướng nghiên cứu khoa học qua [OpenAlex API](https://developers.openalex.org/).

## Tính năng

- Tìm kiếm publication theo chủ đề + bộ lọc (năm, OA, sort)
- Research Dashboard (KPI, trend, citation, top author/journal/paper)
- 30 BI charts (scatter, bubble, heatmap, network, country map…)
- Chart tương tác: chạm điểm/bubble/country để xem số liệu thực
- Dark mode (Settings → Appearance)
- Recent searches, OpenAlex API key config

## Kiến trúc

```text
lib/
  models/       Publication, analytics catalog, extra bundle
  services/     OpenAlexService, AnalyticsCacheService, AppPreferences
  providers/    PublicationProvider, AppNavigationProvider
  screens/      Home, Journal, Analysis, Profile, Advanced Analytics
  widgets/      Charts, search states, skeleton loaders
  theme/        AppPalette, light/dark Material 3 theme
```

Chi tiết: [JOURNAL_TREND_ANALYZER_ARCHITECTURE.md](../JOURNAL_TREND_ANALYZER_ARCHITECTURE.md)

## Yêu cầu

- Flutter SDK 3.x
- Dart ^3.11

## Chạy app

```powershell
cd journal_trend_analyzer_v2
flutter pub get
flutter run
```

### OpenAlex API key (khuyến nghị)

Lấy key miễn phí: [openalex.org/settings/api](https://openalex.org/settings/api)

```powershell
copy dart_defines.example.json dart_defines.local.json
# Sửa OPENALEX_API_KEY trong dart_defines.local.json
.\scripts\run.ps1
```

Hoặc:

```powershell
flutter run --dart-define=OPENALEX_API_KEY=your_key_here
```

## Luồng demo gợi ý

1. **Home** → search `Artificial Intelligence` → mở Journal tab xem kết quả
2. **Analysis** → Research Dashboard → xem KPI + trend charts
3. **Analysis → Explore** → **Open All Charts** → chạm scatter (#8 Top Cited Authors)
4. **Analysis → Explore** → chart **#12 / #13** → chạm bubble trên country map
5. **Profile → Settings** → bật **Dark Mode** → kiểm tra dashboard + analytics

## Kiểm tra chất lượng

```powershell
flutter analyze
flutter test
```

## Dependencies chính

| Package   | Mục đích              |
|-----------|------------------------|
| `provider`| State management       |
| `http`    | OpenAlex REST API      |
| `fl_chart`| Line, bar, pie, scatter|
