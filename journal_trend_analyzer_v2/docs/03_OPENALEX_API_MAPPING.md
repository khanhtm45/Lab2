# OpenAlex API Mapping — Journal Trend Analyzer

> Base URL: `https://api.openalex.org`
> Auth: optional `api_key` param or `mailto` for polite pool

---

## Endpoints Used

### 1. Works (Publications)

#### Search publications
```
GET /works
  ?search={keyword}
  &sort=cited_by_count:desc
  &per-page=20
  &page={n}
  &select=id,title,publication_year,cited_by_count,type,
          authorships,primary_location,open_access,
          abstract_inverted_index,doi,concepts,related_works
  &mailto=your@email.com
```

#### Filter by year
```
GET /works
  ?filter=publication_year:{year},search:{keyword}
  &per-page=100
```

#### Group by field (aggregate stats)
```
GET /works
  ?group_by={field}
  &filter=...optional...
  &per-page=100
  &mailto=your@email.com

# Fields:
  authorships.author.id              → Top Authors
  primary_location.source.id         → Top Journals
  authorships.institutions.id        → Top Institutions
  authorships.institutions.country_code → Top Countries
  concepts.id                        → Top Research Areas
  keywords.id                        → Top Keywords
  type                               → Publication Type Distribution
  language                           → Language Distribution
  open_access.is_oa                  → Open Access Ratio
  publication_year                   → Yearly Trend
```

#### Total count only
```
GET /works
  ?filter=...
  &per-page=1
  &select=id
  → meta.count gives total
```

---

### 2. Sources (Journals)

#### Search journals
```
GET /sources
  ?search={journal_name}
  &filter=type:journal
  &sort=works_count:desc
  &per-page=20
  &select=id,display_name,host_organization_name,issn_l,
          country_code,works_count,cited_by_count,
          homepage_url,type
```

#### Journal profile (by ID)
```
GET /sources/{source_id}
  ?select=id,display_name,issn_l,issn,host_organization_name,
          country_code,works_count,cited_by_count,
          homepage_url,type,description
```

#### Journal yearly trend
```
GET /works
  ?filter=primary_location.source.id:{source_id},
          publication_year:2016-2025
  &group_by=publication_year
```

#### Works in a journal (paginated)
```
GET /works
  ?filter=primary_location.source.id:{source_id}
  &sort=cited_by_count:desc
  &per-page=20
  &page={n}
  &select=id,title,publication_year,cited_by_count,authorships,doi
```

---

### 3. Authors

#### Author profile (by ID)
```
GET /authors/{author_id}
  ?select=id,display_name,orcid,works_count,cited_by_count,
          last_known_institution,affiliations,
          summary_stats,counts_by_year,topics
```

#### Works by author
```
GET /works
  ?filter=authorships.author.id:{author_id}
  &sort=cited_by_count:desc
  &per-page=20
  &page={n}
```

#### Author yearly trend
```
GET /works
  ?filter=authorships.author.id:{author_id},
          publication_year:2016-2025
  &group_by=publication_year
```

---

### 4. Institutions

#### Institution profile
```
GET /institutions/{institution_id}
  ?select=id,display_name,country_code,type,
          works_count,cited_by_count,homepage_url
```

---

### 5. Concepts / Topics

#### Concept detail
```
GET /concepts/{concept_id}
  ?select=id,display_name,level,works_count,cited_by_count,description
```

#### Concept yearly trend
```
GET /works
  ?filter=concepts.id:{concept_id}
  &group_by=publication_year
```

---

## Parsed Response → Model Mapping

### Publication (from `/works` item)

```dart
Publication(
  id:           work['id'],
  title:        work['title'],
  year:         work['publication_year'],
  citations:    work['cited_by_count'],
  type:         work['type'],
  doi:          work['doi'],
  journal:      work['primary_location']['source']['display_name'],
  openAccess:   work['open_access']['is_oa'],
  abstract:     _decodeAbstract(work['abstract_inverted_index']),
  authors:      _parseAuthors(work['authorships']),
  keywords:     _parseKeywords(work['concepts']),
  relatedWorkIds: List.from(work['related_works']),
)
```

### OpenAlexRankedEntity (from group_by result)

```dart
OpenAlexRankedEntity(
  id:    groupResult['key'],
  name:  groupResult['key_display_name'],
  count: groupResult['count'],
)
```

### JournalSourceProfile (from `/sources/{id}`)

```dart
JournalSourceProfile(
  name:        source['display_name'],
  issn:        source['issn_l'],
  publisher:   source['host_organization_name'],
  sourceType:  source['type'],
  homepageUrl: source['homepage_url'],
  country:     source['country_code'],
  worksCount:  source['works_count'],
  citedByCount:source['cited_by_count'],
)
```

---

## Filters Reference

### Global Influential (default dashboard)
```
filter=cited_by_count:>50,publication_year:2016-2025
```

### By topic
```
filter=search:{keyword}
```

### By year
```
filter=publication_year:{year}
```

### By journal
```
filter=primary_location.source.id:{id}
```

### By author
```
filter=authorships.author.id:{id}
```

### Open access only
```
filter=open_access.is_oa:true
```

### Multiple filters (AND)
```
filter=search:{kw},publication_year:{year},open_access.is_oa:true
```

---

## Sort Options

| Sort | Parameter | Use case |
|------|-----------|----------|
| Most Cited | `cited_by_count:desc` | Default, top papers |
| Newest | `publication_date:desc` | Latest research |
| Relevance | (no sort param, use search) | Search relevance |
| Works Count | `works_count:desc` | Journal/author ranking |

---

## Rate Limiting & Best Practices

- Use `mailto` param for polite pool (higher rate limits): `&mailto=your@email.com`
- Use `api_key` for authenticated access (even higher limits)
- Retry on 429 (rate limit) with exponential backoff
- Cache results in memory during session
- Request only needed fields with `select=` to reduce payload size
- Max `per-page=200` (hard limit by OpenAlex)
- Use pagination: `page=1`, `page=2`, etc. (max 200 pages × 200 per page)
