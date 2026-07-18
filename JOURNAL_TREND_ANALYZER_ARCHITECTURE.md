# Journal Trend Analyzer v2

## PRM393 - Mobile Programming Lab 02

> **Codebase:** `journal_trend_analyzer_v2/` — Flutter app với Material 3, Provider, OpenAlex API, 30 BI charts.

---

# 1. Project Overview

Journal Trend Analyzer là ứng dụng Flutter sử dụng OpenAlex API để phân tích xu hướng nghiên cứu khoa học.

Người dùng có thể:

* Tìm kiếm chủ đề nghiên cứu
* Xem bài báo khoa học
* Phân tích xu hướng công bố
* Tìm tác giả / tạp chí nổi bật
* Xem dashboard thống kê và 30 BI visualizations
* Dark mode (Settings → Appearance)

---

# 2. Design Theme

## Academic Analytics Theme (v2)

### Colors — Light

```text
Primary      #1E3A8A  (navy)
Secondary    #4F46E5  (indigo)
Accent       #14B8A6  (teal)
Citation     #F59E0B  (amber)
Background   #F8FAFC
Surface      #FFFFFF
Text         #0F172A
```

### Colors — Dark

```text
Background   #0F172A
Surface      #1E293B
Primary      #818CF8
Accent       #2DD4BF
Text         #F8FAFC
```

### Design Style

* Academic Analytics Platform
* Material Design 3
* Theme-aware via `AppPalette` / `context.palette`
* Clean dashboard + interactive charts (`fl_chart`)

---

# 3. Navigation Structure

```text
Bottom Navigation (4 tabs)

Home        — Search, popular topics, recent searches
Journal     — Publication results + filters
Analysis    — Research dashboard, trends, explore
Profile     — Settings, OpenAlex API, About

Analysis → Explore
  ├── BI Catalog (30 items)
  ├── Open All Charts (Advanced Analytics)
  └── Trending topics
```

---

# 4. Dashboard Screen

## Purpose

Tổng quan về chủ đề nghiên cứu hiện tại.

---

## Components

### Header

```text
Research Dashboard
Current Topic
```

### KPI Cards

```text
Total Publications
Average Citations
Most Active Year
Top Journal
Top Author
Most Influential Paper
```

### Publication Growth Chart

```text
Publication Count By Year
```

### Citation Growth Chart

```text
Citation Count By Year
```

### Quick Insights

```text
Top Journal
Top Author
Top Paper
```

---

## APIs

### Search Topic

```http
GET /works?search={topic}&per_page=200
```

### Top Influential Paper

```http
GET /works?search={topic}&sort=cited_by_count:desc
```

---

## Derived Analytics

### Total Publications

```text
meta.count
```

### Average Citations

```text
sum(cited_by_count) / totalWorks
```

### Most Active Year

```text
groupBy(publication_year)
```

### Top Journal

```text
groupBy(primary_location.source.display_name)
```

### Top Author

```text
groupBy(authorships.author.display_name)
```

---

# 5. Search Screen

## Purpose

Tìm kiếm bài báo khoa học.

---

## Components

### Search Bar

```text
Search research topic...
```

### Suggested Topics

```text
Artificial Intelligence
Machine Learning
IoT
Blockchain
Cybersecurity
Data Science
```

### Filter Button

```text
Publication Year
Citation Count
Open Access
Publication Type
```

### Publication List

Card Information:

```text
Title
Authors
Journal
Publication Year
Citation Count
```

---

## APIs

### Search Publications

```http
GET /works?search={keyword}
```

### Filter By Year

```http
GET /works?search={keyword}&filter=publication_year:2025
```

### Filter Open Access

```http
GET /works?search={keyword}&filter=is_oa:true
```

### Sort By Citation

```http
GET /works?search={keyword}&sort=cited_by_count:desc
```

---

# 6. Publication Detail Screen

## Purpose

Hiển thị thông tin chi tiết bài báo.

---

## Components

### Publication Information

```text
Title
Publication Year
Citation Count
DOI
Language
Type
```

### Authors Section

```text
Author Name
Institution
Country
```

### Journal Section

```text
Journal Name
ISSN
Publisher
```

### Abstract Section

```text
Abstract
```

### Related Papers

```text
Similar Publications
```

---

## APIs

### Get Publication Detail

```http
GET /works/{id}
```

### Related Publications

```http
GET /works?search={topic}
```

---

# 7. Trends Screen

## Purpose

Phân tích xu hướng nghiên cứu.

---

## Components

### Publication Growth

Line Chart

```text
Publication Count By Year
```

### Citation Growth

Bar Chart

```text
Citation Count By Year
```

### Publication Type Distribution

Pie Chart

```text
Article
Review
Book
Dataset
```

### Open Access Ratio

Donut Chart

```text
OA
Non-OA
```

### Language Distribution

Pie Chart

```text
EN
ZH
FR
...
```

---

## APIs

### Trend Data

```http
GET /works?search={topic}&per_page=200
```

---

## Analytics

### Publication Growth

```text
groupBy(publication_year)
```

### Citation Growth

```text
groupBy(publication_year)
sum(cited_by_count)
```

### Publication Type

```text
groupBy(type)
```

### Open Access Ratio

```text
groupBy(is_oa)
```

### Language Distribution

```text
groupBy(language)
```

---

# 8. Insights Screen

## Purpose

Phân tích chuyên sâu.

---

## Components

### Top Influential Papers

```text
Top 20 Most Cited Papers
```

### Top Authors

```text
Top 20 Authors
```

### Top Journals

```text
Top 20 Journals
```

### Top Institutions

```text
Top 20 Institutions
```

### Top Countries

```text
Top 20 Countries
```

---

## APIs

### Most Cited Papers

```http
GET /works?search={topic}&sort=cited_by_count:desc
```

---

## Analytics

### Authors Ranking

```text
groupBy(authorships.author.display_name)
```

### Journal Ranking

```text
groupBy(primary_location.source.display_name)
```

### Institution Ranking

```text
groupBy(authorships.institutions.display_name)
```

### Country Ranking

```text
groupBy(authorships.institutions.country_code)
```

---

# 9. Explore Screen

## Purpose

Khám phá hệ sinh thái nghiên cứu.

---

## Components

### Trending Topics

```text
Generative AI
LLM
AI Agent
Edge AI
IoT Security
```

### Research Domains

```text
Domain
Field
Subfield
```

### Keyword Network

```text
Keyword Relationship Graph
```

### Topic Comparison

```text
AI vs Blockchain
AI vs IoT
```

---

## APIs

### Topics

```http
GET /topics
```

### Keywords

```http
GET /keywords
```

### Domains

```http
GET /domains
```

### Fields

```http
GET /fields
```

### Subfields

```http
GET /subfields
```

---

# 10. Flutter Project Structure

```text
lib/

├── core/
│
├── models/
│   ├── work_model.dart
│   ├── author_model.dart
│   ├── journal_model.dart
│   ├── institution_model.dart
│   ├── dashboard_model.dart
│   └── trend_model.dart
│
├── services/
│   ├── openalex_service.dart
│   └── analytics_service.dart
│
├── providers/
│   ├── dashboard_provider.dart
│   ├── search_provider.dart
│   ├── trend_provider.dart
│   ├── insight_provider.dart
│   └── topic_provider.dart
│
├── screens/
│   ├── dashboard/
│   ├── search/
│   ├── detail/
│   ├── trends/
│   ├── insights/
│   └── explore/
│
├── widgets/
│   ├── kpi_card.dart
│   ├── publication_card.dart
│   ├── author_card.dart
│   ├── journal_card.dart
│   ├── trend_chart.dart
│   ├── pie_chart_widget.dart
│   ├── loading_widget.dart
│   ├── empty_widget.dart
│   └── error_widget.dart
│
└── main.dart
```

---

# 11. Recommended Packages

```yaml
dio
provider
fl_chart
go_router
cached_network_image
shimmer
intl
url_launcher
share_plus
```

---

# 12. Architecture Flow

```text
OpenAlex API
        │
        ▼
OpenAlexService
        │
        ▼
AnalyticsService
        │
        ▼
Provider
        │
        ▼
UI Screens
```

---

# 13. Bonus Features

* Dark Mode
* Skeleton Loading
* Pull To Refresh
* Search History
* Export Chart PNG
* Share Publication
* Retry On Error
* Empty State
* Smooth Animation

Các tính năng này không bắt buộc nhưng giúp ứng dụng đạt chất lượng cao hơn và tạo ấn tượng tốt khi demo.
