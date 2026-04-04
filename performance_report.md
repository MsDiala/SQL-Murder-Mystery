# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Osama Harrab  
**Date:** 2026-04-04  
**Database:** `murder_mystery` (PostgreSQL)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------:|-------------:|------------:|-------------|
| Q1 — Murders in SQL City | 0.114 | 0.076 | 33.3% faster | Yes |
| Q2 — People + license details | 15.580 | 15.905 | 2.1% slower | No |
| Q3 — Gym check-ins Jan 9 | 0.183 | 0.110 | 39.9% faster | Yes |
| Q4 — Gold members + income | 1.564 | 1.625 | 3.9% slower | No meaningful change |
| Q5 — Facebook events 2018 | 4.988 | 4.428 | 11.2% faster | Yes |
| Q6 — Red-haired Tesla drivers | 2.395 | 0.160 | 93.3% faster | Yes |
| Q7 — Interview keyword search | 5.497 | 5.626 | 2.3% slower | No |
| Q8 — Income by car make | 6.588 | 7.598 | 15.3% slower | No |

---

## 1. Queries That Improved the Most

The queries that improved the most were **Q6, Q3, Q1, and Q5**.

### Q6 — Red-haired Tesla drivers
This query showed the biggest improvement, dropping from **2.395 ms** to **0.160 ms**. The reason is that the filter was highly selective: only a few rows matched `hair_color = 'red'` and `car_make = 'Tesla'`. Before indexing, PostgreSQL scanned almost the whole `drivers_license` table and removed more than 10,000 rows. After adding a composite index on `(hair_color, car_make)`, it was able to go directly to the matching rows. The join also benefited from the index on `person(license_id)`.

### Q3 — Gym check-ins Jan 9
This query improved from **0.183 ms** to **0.110 ms**. Before indexing, PostgreSQL used a sequential scan on `get_fit_now_check_in` and removed 2693 rows to find only 10 matches. After adding an index on `check_in_date`, it switched to a bitmap index scan and bitmap heap scan, which is much more efficient for this kind of filter.

### Q1 — Murders in SQL City
This query improved from **0.114 ms** to **0.076 ms**. The gain is not huge in absolute terms because the table is not very large, but the execution plan improved clearly. PostgreSQL changed from a sequential scan to an index scan after adding the composite index on `(city, type)`.

### Q5 — Facebook events 2018
This query improved from **4.988 ms** to **4.428 ms**. PostgreSQL switched from a sequential scan on `facebook_event_checkin` to a bitmap index scan on the `date` column. The improvement was moderate because the query still returns thousands of rows and still needs a join with `person`.

---

## 2. Queries That Did NOT Improve

Some queries showed little improvement or even became slightly slower.

### Q2 — People + license details
This query became slightly slower, from **15.580 ms** to **15.905 ms**. PostgreSQL still used sequential scans and a hash join. The reason is that the query reads almost all rows from both `person` and `drivers_license`, so a full scan is cheaper than using an index.

### Q4 — Gold members + income
This query changed only slightly, from **1.564 ms** to **1.625 ms**. The `get_fit_now_member` table is small, so a sequential scan is acceptable. Also, PostgreSQL was already using the primary key index on `income`, so there was not much room for improvement.

### Q7 — Interview keyword search
This query became slightly slower, from **5.497 ms** to **5.626 ms**. The filter uses `ILIKE '%gym%'` and `ILIKE '%murder%'`, and regular B-tree indexes do not help much with leading-wildcard searches. PostgreSQL still had to scan the full `interview` table.

### Q8 — Income by car make
This query became slower, from **6.588 ms** to **7.598 ms**. It joins and aggregates a large portion of the data from three tables. Since the query reads many rows and groups them, PostgreSQL still preferred sequential scans and hash operations. Indexes are less useful for this kind of workload.

---

## 3. Tradeoffs of Indexing

Indexes are useful because they can make **SELECT**, **WHERE**, and **JOIN** operations much faster. Instead of scanning an entire table, the database can jump directly to the matching rows. This is especially helpful when the filter is selective, like searching for a specific date, city, or a small subset of values.

However, indexes also have costs. Every time the database runs an **INSERT**, **UPDATE**, or **DELETE**, it must also update the related indexes. This adds extra overhead to write operations. In other words, indexes usually improve read performance but can slow down write performance.

Indexes also consume additional storage. Each index is stored separately and takes disk space. In a real production database with many tables and frequent writes, too many indexes can become expensive.

That is why it is not a good idea to index every column. Some columns are rarely used in filters or joins, and some queries read most of the table anyway. In those cases, PostgreSQL may still choose a sequential scan because it is faster. Indexes should be created only when execution plans and query patterns show that they are useful.

---

## 4. Production Recommendation

If this were a real police database handling thousands of queries per day, I would **keep** the following indexes:

- `idx_crime_city_type`
- `idx_checkin_date`
- `idx_facebook_date`
- `idx_person_license`
- `idx_license_hair_car`

I would keep these because they support the queries that showed clear improvements. In particular, `idx_license_hair_car` had the strongest impact in Q6, and `idx_checkin_date` and `idx_crime_city_type` also improved selective lookups.

I would also likely keep:

- `idx_facebook_person`

Even though it did not clearly change the observed plan in this test, it may still help with other joins involving `facebook_event_checkin.person_id`.

I would be more cautious about adding indexes for text search in `interview`, because the wildcard search in Q7 does not benefit from a regular B-tree index. If keyword searching were common in production, I would consider a specialized text-search index instead of a normal one.

Overall, I would keep the indexes that helped selective filters and join keys, and avoid keeping indexes that do not show evidence of real benefit. The final decision should be based on actual workload patterns and measured query performance, not guesswork.

---

*© 2026 LevelUp Economy. All rights reserved.*