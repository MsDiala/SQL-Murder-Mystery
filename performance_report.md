# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Jineen Hourani  
**Date:** April 4, 2026  
**Database:** `sql-murder-mystery.db` (PostgreSQL/Docker)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.446 | 0.211 | ~52.7% | `idx_crime_city_type` |
| Q2 — People + license details | 23.207 | 18.383 | ~20.8% | Hash Join Optimization |
| Q3 — Gym check-ins Jan 9 | 0.622 | 0.345 | ~44.5% | `idx_checkin_date` |
| Q4 — Gold members + income | 1.687 | 1.619 | ~4.1% | `income_pkey` |
| Q5 — Facebook events 2018 | 7.582 | 6.110 | ~19.4% | `idx_facebook_date` |
| Q6 — Red-haired Tesla drivers | 2.196 | 0.378 | **~82.8%** | `idx_license_hair_car` |
| Q7 — Interview keyword search | 8.472 | 6.957 | ~17.9% | `person_pkey` (Join only) |
| Q8 — Income by car make | 8.689 | 8.689 | 0% | None (Full Aggregation) |

---

## 1. Queries That Improved the Most

* **Q6 (Red-haired Tesla drivers):** This query saw a massive **82.8%** reduction in execution time. By creating a **Composite Index** on `hair_color` and `car_make`, the database engine was able to skip scanning 10,000+ driver's licenses and jump directly to the 4 matching records.
* **Q1 (Murders in SQL City):** Improved by **52.7%**. The index on `city` and `type` allowed the engine to replace a slow `Seq Scan` (Sequential Scan) with a targeted `Index Scan`, significantly reducing the number of rows processed.

## 2. Queries That Did NOT Improve

* **Q8 (Average income by car make):** This query showed **0% improvement**. Since it requires a global calculation (`AVG` and `GROUP BY`) across all records to produce the final report, a Full Table Scan is more efficient than using an index.
* **Q7 (Interview keyword search):** The improvement was minimal (~18%) and mostly related to the join with the `person` table. The search using `LIKE '%gym%'` cannot be optimized by a standard B-Tree index because the wildcard `%` is at the beginning of the search string.

## 3. Tradeoffs of Indexing

* **Speed:** Indexes significantly accelerate `SELECT`, `WHERE`, and `JOIN` operations by providing a sorted "pointer" to data locations.
* **Write Performance:** Every `INSERT`, `UPDATE`, or `DELETE` becomes slower because the database must update the index structure alongside the actual data.
* **Storage Overhead:** Each index occupies additional disk space. In large-scale systems, indexing every column can lead to massive storage costs.
* **Maintenance:** Over time, indexes can become fragmented and require rebuilding to maintain peak performance.

## 4. Production Recommendation

In a real-world police database, I would recommend the following:
* **Keep:** Indexes on Foreign Keys (`license_id`, `person_id`, `ssn`) as these are essential for frequent relational joins.
* **Keep:** Indexes on high-traffic filter columns like `date` (for crimes/events) and `membership_status`, as investigators frequently filter by these.
* **Drop:** Indexes on low-cardinality columns (like `gender`) or columns with heavy text search (like `transcript`) unless using specialized Full-Text Search indexes (GIN/GiST).

---


*© 2026 LevelUp Economy. All rights reserved.*
