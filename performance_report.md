# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Bashar Albdour
**Date:** 02-04-2026
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.503 | 0.119 | ~4× faster | Yes |
| Q2 — People + license details | 33.982 | 24.366 | Moderate (~30%) | No |
| Q3 — Gym check-ins Jan 9 | 0.682 | 0.382 | Improved | Yes |
| Q4 — Gold members + income | 3.575 | 3.464 | No significant change | No |
| Q5 — Facebook events 2018 | 14.931 | 6.801 | ~2× faster | Yes |
| Q6 — Red-haired Tesla drivers | 3.860 | 0.194 | ~20× faster | Yes |
| Q7 — Interview keyword search | 17.692 | 7.581 | Improved (caching) | No |
| Q8 — Income by car make | 21.454 | 22.786 | No improvement | No |

---

## 1. Queries That Improved the Most

The queries that showed the most improvement were Q5 and Q6.

- **Q5 (Facebook events in 2018)** improved significantly after adding an index on `facebook_event_checkin(date)`.  
  Before indexing, PostgreSQL performed a full table scan on a large table (~20,000 rows). After indexing, it used a Bitmap Index Scan to access only relevant rows, reducing execution time from ~14.9 ms to ~6.8 ms.

- **Q6 (Red-haired Tesla drivers)** showed the largest improvement.  
  A composite index on `(hair_color, car_make)` allowed PostgreSQL to directly locate matching rows. The execution time dropped from ~3.86 ms to ~0.19 ms (~20× faster).

- **Q1 and Q3** also improved:
  - Q1 used a composite index on `(city, type)` to avoid scanning the full table.
  - Q3 used a Bitmap Index Scan on `check_in_date`, improving filtering efficiency.

---

## 2. Queries That Did NOT Improve

Some queries showed little or no improvement:

- **Q2**:  
  PostgreSQL continued using sequential scans because the query returns almost all rows (~10,000 rows). In such cases, sequential scanning is more efficient than using an index.

- **Q4**:  
  Minimal improvement was observed because:
  - One table is small (`get_fit_now_member`)
  - The join with `income` was already optimized using a primary key index  
  The execution plan was already efficient.

- **Q7**:  
  No index improvement was possible due to wildcard search:
  ```sql
  ILIKE '%gym%' OR ILIKE '%murder%'
  This prevents index usage. The performance improvement observed was due to caching, not indexing.

**Q8** :
No improvement was observed because the query performs aggregation (GROUP BY) over large datasets. PostgreSQL must process all rows, so indexes provide little benefit.

---

## 3. Tradeoffs of Indexing

Indexes provide several benefits and drawbacks:

-Faster reads:
Indexes significantly speed up SELECT queries, especially those using WHERE conditions and JOINs.

-Slower writes:
INSERT, UPDATE, and DELETE operations become slower because indexes must also be updated.

-Storage overhead:
Each index requires additional disk space.

-Selective usage:
Not all columns should be indexed. Indexes are most useful for frequently filtered or joined columns, not for small tables or full-table operations.

---

## 4. Production Recommendation

For a production system, the following indexes should be kept:

idx_crime_city_type → improves filtering (Q1)
idx_checkin_date → improves date filtering (Q3)
idx_facebook_date → critical for large table filtering (Q5)
idx_facebook_person_id → improves joins (Q5)
idx_license_hair_car → highly effective composite index (Q6)
idx_person_license_id → useful for joins across multiple queries

Indexes that should NOT be prioritized:

Indexes on small tables (e.g., get_fit_now_member)
Indexes for wildcard text search (Q7)
Additional indexes for aggregation-heavy queries (Q8)

---

*© 2026 LevelUp Economy. All rights reserved.*
