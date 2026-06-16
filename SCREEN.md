# Journal Trend Analyzer

# UI/UX Screen Design Specification

Link: Stitch: https://stitch.withgoogle.com/projects/9540019588922866460?node-id=9f232b6a667e4695bca109ccb09b610e

---

# 1. Design Philosophy

Journal Trend Analyzer là ứng dụng phân tích xu hướng nghiên cứu khoa học sử dụng dữ liệu từ OpenAlex.

Mục tiêu thiết kế:

* Học thuật
* Chuyên nghiệp
* Dễ đọc dữ liệu
* Trực quan hóa thông tin
* Tối ưu trải nghiệm trên thiết bị di động

---

# 2. Design System

## Color Palette

### Primary

```text
#2563EB
```

### Secondary

```text
#3B82F6
```

### Accent

```text
#60A5FA
```

### Background

```text
#F8FAFC
```

### Card

```text
#FFFFFF
```

### Text

```text
#0F172A
```

---

## Typography

### Heading

```text
Font Weight: Bold
Size: 24
```

### Section Title

```text
Font Weight: SemiBold
Size: 18
```

### Body

```text
Font Weight: Regular
Size: 14
```

---

# 3. Navigation Structure

```text
Bottom Navigation

Dashboard
Search
Trends
Insights
Explore
```

---

# 4. Dashboard Screen

## Purpose

Cung cấp tổng quan về chủ đề nghiên cứu đang được phân tích.

---

## Layout

### Header

```text
Research Dashboard

Current Topic:
Artificial Intelligence
```

Action Buttons:

```text
Search
Refresh
```

---

### KPI Section

Hiển thị 6 KPI Cards.

#### Card 1

```text
Total Publications
```

#### Card 2

```text
Average Citations
```

#### Card 3

```text
Most Active Year
```

#### Card 4

```text
Top Journal
```

#### Card 5

```text
Top Author
```

#### Card 6

```text
Most Influential Paper
```

---

### Publication Growth

Line Chart:

```text
Year
Publication Count
```

---

### Citation Growth

Bar Chart:

```text
Year
Citation Count
```

---

### Quick Insights

Cards:

```text
Top Journal
Top Author
Top Paper
```

---

## User Actions

* Change Topic
* Refresh Data
* View Insight

---

# 5. Search Screen

## Purpose

Tìm kiếm bài báo khoa học.

---

## Layout

### Search Bar

```text
Search research topic...
```

Search Icon

Filter Icon

Voice Search Icon

---

### Suggested Topics

```text
Artificial Intelligence
Machine Learning
Data Science
IoT
Blockchain
Cybersecurity
```

---

### Filter Section

Filter by:

```text
Publication Year
Citation Count
Open Access
Publication Type
```

---

### Publication List

Publication Card

#### Information

```text
Title
Authors
Journal
Publication Year
Citation Count
```

---

### Sort

```text
Newest
Most Cited
Oldest
A-Z
```

---

## User Actions

* Search
* Filter
* Sort
* Open Detail

---

# 6. Publication Detail Screen

## Purpose

Hiển thị thông tin chi tiết bài báo.

---

## Layout

### Hero Section

```text
Publication Title
```

Metadata:

```text
Publication Year
Citation Count
Journal
Language
```

---

### DOI Section

```text
DOI
```

Action:

```text
Copy DOI
Open DOI
```

---

### Authors Section

Hiển thị danh sách tác giả.

Thông tin:

```text
Author Name
Institution
Country
```

---

### Abstract Section

```text
Abstract
```

Expand / Collapse

---

### Statistics Section

```text
Citation Count
Publication Type
Open Access
```

---

### Related Publications

Horizontal List

Thông tin:

```text
Title
Year
Citation
```

---

## User Actions

* Share Publication
* Open DOI
* Copy DOI
* Open Related Paper

---

# 7. Trends Screen

## Purpose

Phân tích xu hướng nghiên cứu.

---

## Layout

### Publication Growth Chart

Line Chart

```text
Publication Count By Year
```

---

### Citation Growth Chart

Bar Chart

```text
Citation Count By Year
```

---

### Publication Type Distribution

Pie Chart

```text
Article
Review
Book
Dataset
```

---

### Open Access Ratio

Donut Chart

```text
OA
Non-OA
```

---

### Language Distribution

Pie Chart

```text
English
Chinese
French
Other
```

---

### Top Publication Years

Table

```text
Year
Publication Count
```

---

## User Actions

* Filter Year Range
* Export Chart
* Compare Trend

---

# 8. Insights Screen

## Purpose

Hiển thị các thống kê chuyên sâu.

---

## Layout

### Top Influential Papers

Top 20 Ranking

Thông tin:

```text
Rank
Title
Citation Count
Year
```

---

### Top Authors

Thông tin:

```text
Author Name
Publication Count
Citation Count
```

---

### Top Journals

Thông tin:

```text
Journal Name
Publication Count
```

---

### Top Institutions

Thông tin:

```text
Institution Name
Publication Count
```

---

### Top Countries

Thông tin:

```text
Country
Publication Count
```

---

## User Actions

* Sort
* Filter
* Open Details

---

# 9. Explore Screen

## Purpose

Khám phá hệ sinh thái nghiên cứu.

---

## Layout

### Trending Topics

Cards:

```text
Generative AI
Large Language Models
AI Agents
Edge AI
IoT Security
```

---

### Research Domains

Tree View

```text
Domain
 └─ Field
      └─ Subfield
```

---

### Keyword Network

Graph Visualization

```text
AI
ML
Deep Learning
NLP
```

---

### Topic Comparison

Compare:

```text
AI vs Blockchain
AI vs IoT
AI vs Cybersecurity
```

Comparison Metrics:

```text
Publications
Citations
Authors
Journals
```

---

## User Actions

* Explore Topic
* Compare Topics
* View Domain Details

---

# 10. Bottom Sheets & Dialogs

## Topic Selector

Cho phép chọn nhanh chủ đề.

---

## Filter Bottom Sheet

Bao gồm:

```text
Publication Year
Citation Count
Open Access
Publication Type
```

---

## Sort Bottom Sheet

```text
Newest
Oldest
Most Cited
Alphabetical
```

---

## Author Detail Bottom Sheet

Thông tin:

```text
Author Name
Institution
Publication Count
Citation Count
```

---

## Journal Detail Bottom Sheet

Thông tin:

```text
Journal Name
Publication Count
Top Papers
```

---

# 11. Responsive Requirements

Thiết kế phải hoạt động tốt trên:

```text
Android Phone

6.1 inch
6.5 inch
6.7 inch

Android Emulator
```

---

# 12. User Experience Enhancements

## Loading State

Skeleton Loading

Shimmer Effect

---

## Empty State

No Data Found

---

## Error State

Retry Button

---

## Refresh

Pull To Refresh

---

## Theme

Light Mode
Dark Mode

---

# 13. Expected User Flow

```text
Dashboard
    ↓
Search Topic
    ↓
View Publications
    ↓
Open Publication Detail
    ↓
Analyze Trends
    ↓
Explore Insights
    ↓
Compare Research Topics
```

Kết quả cuối cùng là một ứng dụng phân tích nghiên cứu khoa học hiện đại, trực quan và đáp ứng đầy đủ yêu cầu của PRM393 Lab 02.
