# OpenAlex API Reference — Journal Trend Analyzer

> Full reference for all OpenAlex endpoints used in the app.
> Documentation: https://docs.openalex.org

---

## Base Configuration

```
Base URL:    https://api.openalex.org
Protocol:    HTTPS only
Format:      JSON
Auth:        Optional (api_key param or polite pool via mailto)
Rate limit:  10 req/sec (polite) · 100K req/day (authenticated)
```

---

## 1. Works Endpoint

**Path:** `/works`

### Purpose
Retrieve scientific papers/publications. The core entity used throughout the app.

### Key Query Parameters

| Param | Type | Description |
|-------|------|-------------|
| `search` | string | Full-text search across title/abstract |
| `filter` | string | Comma-separated filters (field:value) |
| `sort` | string | `cited_by_count:desc`, `publication_date:desc` |
| `per-page` | int | 1–200 (default: 25) |
| `page` | int | Pagination (default: 1) |
| `group_by` | string | Aggregate by field (returns counts) |
| `select` | string | Comma-separated fields to return |
| `mailto` | string | Email for polite pool access |
| `api_key` | string | API key for higher rate limits |

### Filter Examples

```
# By topic (search)
filter=search:machine learning

# By year range
filter=publication_year:2020-2024

# By journal (source ID)
filter=primary_location.source.id:S205292171

# By author ID
filter=authorships.author.id:A2043481726

# By institution ID
filter=authorships.institutions.id:I27837315

# By country code
filter=authorships.institutions.country_code:US

# Highly cited (threshold)
filter=cited_by_count:>100

# Open access only
filter=open_access.is_oa:true

# Combined
filter=search:AI,publication_year:2020-2024,cited_by_count:>10
```

### group_by Values

| group_by value | App usage |
|----------------|-----------|
| `publication_year` | Yearly trend chart |
| `authorships.author.id` | Top authors ranking |
| `primary_location.source.id` | Top journals |
| `authorships.institutions.id` | Top institutions |
| `authorships.institutions.country_code` | Top countries |
| `concepts.id` | Research areas/topics |
| `keywords.id` | Top keywords |
| `type` | Publication type distribution |
| `language` | Language distribution |
| `open_access.is_oa` | Open access ratio |

### Select Fields (optimization)

```
# Full publication card
select=id,title,publication_year,cited_by_count,type,
       authorships,primary_location,open_access,
       abstract_inverted_index,doi,concepts,related_works

# Citation only (fast)
select=id,cited_by_count

# Trend only
select=id,publication_year

# Analytics
select=id,title,publication_year,cited_by_count,
       authorships,concepts,keywords,related_works,primary_location
```

### Response Structure

```json
{
  "meta": {
    "count": 284713456,
    "db_response_time_ms": 12,
    "page": 1,
    "per_page": 20,
    "next_cursor": "*"
  },
  "results": [
    {
      "id": "https://openalex.org/W2741809807",
      "title": "Attention Is All You Need",
      "publication_year": 2017,
      "cited_by_count": 98450,
      "type": "article",
      "doi": "https://doi.org/10.48550/arXiv.1706.03762",
      "authorships": [
        {
          "author": {
            "id": "https://openalex.org/A2043481726",
            "display_name": "Ashish Vaswani"
          },
          "institutions": [
            {
              "id": "https://openalex.org/I1299303494",
              "display_name": "Google Brain",
              "country_code": "US"
            }
          ]
        }
      ],
      "primary_location": {
        "source": {
          "id": "https://openalex.org/S1983995261",
          "display_name": "arXiv (Cornell University)",
          "type": "repository"
        }
      },
      "open_access": {
        "is_oa": true,
        "oa_status": "gold"
      },
      "abstract_inverted_index": { ... },
      "concepts": [
        {
          "id": "https://openalex.org/C154945302",
          "display_name": "Artificial Intelligence",
          "score": 0.95,
          "level": 1
        }
      ],
      "related_works": [
        "https://openalex.org/W1516819612"
      ]
    }
  ],
  "group_by": null
}
```

### group_by Response Structure

```json
{
  "meta": { "count": 5432000, ... },
  "results": [],
  "group_by": [
    {
      "key": "https://openalex.org/A2043481726",
      "key_display_name": "Yoshua Bengio",
      "count": 847
    }
  ]
}
```

---

## 2. Sources Endpoint (Journals)

**Path:** `/sources`

### Key Parameters

| Param | Description |
|-------|-------------|
| `search` | Journal name search |
| `filter` | `type:journal` |
| `sort` | `works_count:desc`, `cited_by_count:desc` |
| `select` | Fields to include |

### Source Object Fields

```json
{
  "id": "https://openalex.org/S205292171",
  "display_name": "Nature",
  "issn_l": "0028-0836",
  "issn": ["0028-0836", "1476-4687"],
  "host_organization_name": "Springer Nature",
  "country_code": "GB",
  "type": "journal",
  "works_count": 91204,
  "cited_by_count": 15489320,
  "homepage_url": "https://www.nature.com",
  "apc_usd": 9500,
  "is_in_doaj": false
}
```

---

## 3. Authors Endpoint

**Path:** `/authors`

### Author Object Fields

```json
{
  "id": "https://openalex.org/A2043481726",
  "display_name": "Yoshua Bengio",
  "orcid": "https://orcid.org/0000-0002-4056-4241",
  "works_count": 847,
  "cited_by_count": 350241,
  "last_known_institution": {
    "display_name": "University of Montreal",
    "country_code": "CA"
  },
  "summary_stats": {
    "2yr_mean_citedness": 124.5,
    "h_index": 156,
    "i10_index": 450
  },
  "counts_by_year": [
    { "year": 2023, "works_count": 45, "cited_by_count": 12450 },
    { "year": 2022, "works_count": 52, "cited_by_count": 18900 }
  ]
}
```

---

## 4. Institutions Endpoint

**Path:** `/institutions`

### Institution Object Fields

```json
{
  "id": "https://openalex.org/I27837315",
  "display_name": "Massachusetts Institute of Technology",
  "country_code": "US",
  "type": "education",
  "works_count": 285420,
  "cited_by_count": 12845000,
  "homepage_url": "https://mit.edu"
}
```

---

## 5. Concepts Endpoint

**Path:** `/concepts`

### Concept Object Fields

```json
{
  "id": "https://openalex.org/C154945302",
  "display_name": "Artificial Intelligence",
  "level": 1,
  "works_count": 2845000,
  "cited_by_count": 45000000,
  "description": "Intelligence demonstrated by machines..."
}
```

---

## 6. Abstract Decoding

OpenAlex encodes abstracts as **inverted index** (word → list of positions).

```dart
static String decodeAbstract(Map<String, dynamic>? invertedIndex) {
  if (invertedIndex == null) return '';
  final wordPositions = <int, String>{};
  invertedIndex.forEach((word, positions) {
    for (final pos in positions as List) {
      wordPositions[pos as int] = word;
    }
  });
  final sorted = wordPositions.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return sorted.map((e) => e.value).join(' ');
}
```

---

## 7. ID Formats

OpenAlex uses full URLs as IDs:
- Works: `https://openalex.org/W2741809807`
- Authors: `https://openalex.org/A2043481726`
- Sources: `https://openalex.org/S205292171`
- Institutions: `https://openalex.org/I27837315`
- Concepts: `https://openalex.org/C154945302`

**Short ID extraction:**
```dart
String shortId(String fullId) => fullId.split('/').last;
// "https://openalex.org/W2741809807" → "W2741809807"
```

---

## 8. Pagination

```
GET /works?per-page=20&page=1   → items 1–20
GET /works?per-page=20&page=2   → items 21–40
...
max page: depends on total count
```

Check `meta.count` for total results. Calculate total pages:
```dart
int totalPages = (meta.count / perPage).ceil();
bool hasMore = currentPage * perPage < meta.count;
```

---

## 9. Error Responses

| Status | Meaning | Action |
|--------|---------|--------|
| 200 | OK | Parse response |
| 400 | Bad request (invalid filter) | Show error message |
| 403 | Invalid API key | Clear key, prompt user |
| 429 | Rate limited | Retry after delay |
| 500 | Server error | Retry |
| 502/503/504 | Temporary unavailable | Retry with backoff |

```json
{
  "error": "Invalid filter: publication_year must be a number or range",
  "message": "..."
}
```
