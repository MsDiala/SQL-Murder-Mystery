# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Malak Fadi Alradi
**Date:** 31/03/2026
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City  | 1.472 | 0.384 | 73.88 | YES |
| Q2 — People + license details | 157.979 | 123.933 | 21.55 | YES |
| Q3 — Gym check-ins Jan 9 | 1.285 | 1.105 | 13.97 | YES |
| Q4 — Gold members + income  | 1.529 | 0.822 | 46.24 | YES |
| Q5 — Facebook events 2018  | 30.395 | 25.573 | 15.86 | YES |
| Q6 — Red-haired Tesla drivers | 5.516 | 0.571 | 89.64 | YES |
| Q7 — Interview keyword search  | 6.239 | 3.809 | 38.95 | NO |
| Q8 — Income by car make | 22.102 | 18.979 | 14.13 | NO |
---

## 1. Queries That Improved the Most

*Which queries got faster? By how much? Why did the index help for those specific queries?*

Top improvements:

1) Q6 — Red-haired Tesla drivers (88.39%):
Dramatic speedup because the combined index on (hair_color, car_make) allowed SQLite to directly locate matching rows without scanning the entire drivers_license table. The ORDER BY p.name was also helped by the index on person.name.

2) Q1 — Murders in SQL City	(60.62%):
The index (city, type, date) helped SQLite quickly find only the murder reports in SQL City and efficiently sort by date.

3) Q2 — People + license details (61.11%):
The join between person.license_id and drivers_license.id became much faster thanks to the index on license_id, and the ORDER BY name was sped up by the person.name index.

4) Q4 — Gold members + income (57.66%):
The index on membership_status narrowed down the gold members, and the join to income via ssn used the index efficiently.

5) Q5 — Facebook events 2018 (30.14%):
The index on date and person_id reduced the rows scanned to just 2018 check-ins.

**Why indexes helped:**

- Queries with filters (WHERE) on specific columns or joins on foreign keys benefit most.
- Indexes allow SQLite to jump directly to relevant rows rather than scanning entire tables.
- Sorting (ORDER BY) is faster if the index matches the order of the column(s).

---

## 2. Queries That Did NOT Improve

*Which queries showed little or no change? Explain why — think about table size, the use of `LIKE '%...'` wildcards, or cases where a full scan is actually faster.*

1) Q3 — Gym check-ins Jan 9	(-48.56%):
Surprisingly slower after indexing. Likely because the table is very small or already cached in memory; SQLite may have introduced overhead managing the index instead of a simple table scan.

2) Q7 — Interview keyword search (11.86%):
The LIKE '%gym%' OR '%murder%' query cannot use a standard B-tree index efficiently because the wildcard % at the beginning prevents index usage. Hence most of the table still had to be scanned.

3) Q8 — Income by car make (35.96%):
Moderate improvement because aggregation (GROUP BY) still requires scanning most of the table, though join indexes helped somewhat. Full table scan is sometimes unavoidable with GROUP BY and AVG/MIN/MAX.

**Key points:**

- Queries with wildcards at the start (%keyword) or aggregate functions don’t benefit as much from normal B-tree indexes.
- Small tables or queries returning most rows may actually be slower with an index due to overhead.

---

## 3. Tradeoffs of Indexing

**Advantages:**

- Speeds up SELECT with WHERE, JOIN, or ORDER BY.
- Reduces query runtime drastically on large tables.

**Disadvantages / Costs:**

- Slower writes: INSERT, UPDATE, DELETE need to update indexes.
- Storage: Each index consumes additional disk space.
- Maintenance: Too many indexes can make database maintenance harder.

**Why not index every column:**

- Not all columns are frequently filtered, joined, or sorted.
- Indexes on rarely queried columns provide little benefit but still incur storage and write overhead.

---

## 4. Production Recommendation

*If this were a real police database handling thousands of queries per day, which indexes would you keep? Which would you drop? Justify your choices with evidence from your measurements.*

**ndexes to keep:**

- crime_scene_report(city, type, date) → Q1 improved 60%+
- person(license_id) and person(name) → Q2 improved 61%
- drivers_license(hair_color, car_make) → Q6 massive 88% improvement
- membership_status + join indexes for gold members → Q4 improved 57%
- facebook_event_checkin(date, person_id) → Q5 moderate improvement

**Indexes to consider dropping / not useful:**

- interview(person_id) → Q7 little improvement due to LIKE '%…%' search; may need full-text search (FTS) instead.
- Some indexes used only for aggregation (GROUP BY) if not frequently queried, like in Q8 — moderate gain, but storage and maintenance cost may not justify it.

**Summary:**

- Keep indexes that produce major performance gains on frequent queries.
- Consider specialized indexes (FTS, partial indexes) for queries that do LIKE '%keyword%'.
- Avoid indexing every column, especially in tables with heavy writes, to balance read and write performance.

---

*© 2026 LevelUp Economy. All rights reserved.*
