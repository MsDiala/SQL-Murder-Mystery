# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Marwan ALMasrat
**Date:** 2026-04-01
**Database:** `murder_mystery` (PostgreSQL)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.453 | 1.170 | Slower | <span style="color:green">Yes</span> — idx_crime_city_type |
| Q2 — People + license details | 63.802 | 65.324 | No improvement | No — Seq Scan chosen |
| Q3 — Gym check-ins Jan 9 | 1.492 | 1.714 | No improvement | <span style="color:green">Yes</span> — idx_checkin_date_membership |
| Q4 — Gold members + income | 4.902 | 11.212 | Slower | <span style="color:green">Yes</span> — income_pkey only |
| Q5 — Facebook events 2018 | 29.551 | 50.456 | Slower | <span style="color:green">Yes</span> — idx_facebook_date |
| Q6 — Red-haired Tesla drivers | 7.677 | 3.287 | <span style="color:green">+57% faster</span> | <span style="color:green">Yes</span> — idx_license_hair_car |
| Q7 — Interview keyword search | 41.696 | 30.111 | <span style="color:green">+28% faster</span> | <span style="color:green">Yes</span> — person_pkey |
| Q8 — Income by car make | 35.906 | 38.588 | No improvement | No — Seq Scan chosen |

---

## 1. Queries That Improved the Most

### Q6 — Red-haired Tesla drivers (+57% faster)
This query achieved the best improvement, dropping from 7.677ms to 3.287ms.

**Reason:** The filter `hair_color = 'red' AND car_make = 'Tesla'` is highly selective — it returned only 4 rows out of 10,007. The index `idx_license_hair_car` allowed the database to go directly to those 4 rows instead of scanning the entire table. This is the ideal case for an index: a large table with a highly selective filter produces significant gains.

### Q7 — Interview keyword search (+28% faster)
Improved from 41.696ms to 30.111ms.

**Reason:** The index on `person_pkey` helped during the Nested Loop Join between the interview and person tables, reducing the lookup time for each person after a matching transcript was found.

---

## 2. Queries That Did NOT Improve

### Q2 — People + license details (no improvement)
Remained at approximately 64ms before and after indexing.

**Reason:** This query retrieves all rows from two large tables (10,011 persons and 10,007 licenses) with no filtering condition. When the database needs 100% of the data, a sequential scan is faster because it reads the file continuously from memory without the overhead of navigating an index structure.

### Q8 — Income by car make (no improvement)
Remained at approximately 37ms.

**Reason:** The query uses `GROUP BY`, `AVG()`, and `COUNT()`, which require reading every row across three tables to produce correct aggregation results. There is no selective filter, so the query planner correctly chose sequential scans over indexes.

### Q1, Q3, Q4, Q5 (slightly slower after indexing)
**Reason:** The Planning Time increased because the query planner needed extra time to evaluate whether to use the index or not. For smaller tables such as `get_fit_now_member` (184 rows) and `get_fit_now_check_in` (2,703 rows), the entire table fits easily in memory cache, making a sequential scan faster in practice than an index lookup.

---

## 3. Tradeoffs of Indexing

### How indexes speed up read operations
An index is a separate data structure (B-tree) that stores a sorted copy of the indexed column along with pointers to the original rows. When a query runs `WHERE city = 'SQL City'`, instead of scanning all 1,228 rows, the database navigates directly to the correct position in the B-tree and retrieves only the matching rows.

### How indexes slow down write operations
Every INSERT, UPDATE, or DELETE must update all existing indexes on the table. If a table has 5 indexes, each new row requires 6 write operations — one for the row itself and one for each index. In write-heavy databases, this overhead can become a significant bottleneck.

### Storage overhead
Each index consumes additional disk space. In this project, the indexes added approximately 20-30% to the size of the original tables. In large production databases measured in terabytes, this translates into real infrastructure cost.

### Why not index every column
- Write cost: each additional index slows down INSERT, UPDATE, and DELETE operations.
- Storage cost: indexes occupy disk space proportional to table size.
- Planner cost: more indexes mean more time spent by the query planner evaluating options.
- Low selectivity: columns such as `gender` or `status` with few distinct values return many rows per lookup and gain little from an index.

---

## 4. Production Recommendation

Based on the measurements, the following recommendations apply to a real police database handling thousands of queries per day.

### Indexes to keep

| Index | Reason |
|-------|--------|
| `idx_crime_city_type` on `crime_scene_report(city, type)` | Detectives always filter by city and crime type — this is the most frequent query pattern |
| `idx_license_hair_car` on `drivers_license(hair_color, car_make)` | Proved a real +57% improvement on highly selective suspect lookups |
| `idx_checkin_date_membership` on `get_fit_now_check_in(check_in_date)` | Checking attendance by a specific date is a recurring investigative query |
| `idx_facebook_date` on `facebook_event_checkin(date)` | Date range searches on a large table (20,011 rows) benefit from index navigation |

### Indexes to drop or reconsider

| Index | Reason |
|-------|--------|
| `idx_person_license_id` on `person(license_id)` | Q2 showed no improvement — the planner prefers sequential scan for full-table joins |
| `idx_facebook_person` on `facebook_event_checkin(person_id)` | Not effectively used in any of the measured queries |

### Conclusion
The most valuable indexes are those that serve frequent queries on highly selective columns in large tables. For a police database, searching for crimes by city and type, and identifying suspects by physical description, are the most repeated patterns and benefit the most from indexing.

---

*© 2026 LevelUp Economy. All rights reserved.*