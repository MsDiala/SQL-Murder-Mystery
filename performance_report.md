# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** majd albashtawi
**Date:** 31/3/2026
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement (%) | Index Used? |
|-------|---------------|-------------|----------------|-------------|
| Q1 — Murders in SQL City | 0.446 | 0.249 | 44.06 | YES |
| Q1 — Murders in SQL City | 0.446 | 0.249 | 44.06 | YES |
| Q2 — People + license details | 49.381 | 28.454 | 42.38 | YES |
| Q3 — Gym members checked in Jan 9 | 0.335 | 0.507 | -51.14 | YES |
| Q4 — Gold members and income | 0.541 | 0.571 | -5.64 | YES |
| Q5 — Facebook events 2018 | 13.457 | 12.652 | 5.98 | YES |
| Q6 — Red-haired Tesla drivers | 1.608 | 0.301 | 81.3 | YES |
| Q7 — Interview keyword search | 2.079 | 2.132 | -2.58 | NO |
| Q8 — Average income by car make | 11.788 | 8.931 | 24.24 | NO |


---

## 1. Queries That Improved the Most

Q6 — Red-haired Tesla drivers: This query saw the most significant improvement (81.3%). The index allowed the engine to jump directly to specific car makes and hair colors, bypassing a slow manual scan of the entire drivers_license table.

Q1 — Murders in SQL City: Improved by 44.06%. By indexing city and date columns, the database filtered out irrelevant crime reports instantly, which is much faster than a sequential scan.

Q2 — People + license details: Improved by 42.38%. Since this query involves a JOIN between large tables, indexing the foreign keys reduced the complexity of matching rows between person and drivers_license.

---

## 2. Queries That Did NOT Improve

Q3 & Q4 (Small Data/Overhead): These queries actually performed worse after indexing (down by 51.14% and 5.64%). This happens when a table is very small; the "cost" of the engine opening and searching the index file is higher than simply reading the small table from start to finish.

Q7 — Interview keyword search: The index was NOT used. This is likely due to using LIKE '%keyword%'. When a wildcard (%) is at the start of a string, B-tree indexes cannot be used, forcing a full table scan.

Q8 — Income by car make: The index was NOT used. The slight time difference is likely due to system caching or background CPU fluctuations rather than the index itself.

---

## 3. Tradeoffs of Indexing

Speed vs. Maintenance: While indexes dramatically speed up SELECT and JOIN operations, they slow down INSERT, UPDATE, and DELETE because the database must update the index every time the data changes.

Storage Space: Each index creates a separate data structure on the disk. For large databases, having too many indexes can significantly increase storage costs.

Optimization Strategy: Indexing every column is inefficient. You should only index columns used frequently in WHERE clauses or JOIN conditions for large datasets.

---

## 4. Production Recommendation

Based on the measurements, I recommend the following for a production environment:

Keep indexes for Q1, Q2, and Q6: These provided clear, measurable performance gains on complex queries.

Drop indexes for Q3 and Q4: The overhead of maintaining these indexes isn't worth it, as the queries are fast enough without them (and actually slowed down with them).

Refactor Q7: If keyword searching is a frequent task, we should consider a Full-Text Search (FTS) index rather than a standard B-tree index, which failed to help here.

---

*© 2026 LevelUp Economy. All rights reserved.*
