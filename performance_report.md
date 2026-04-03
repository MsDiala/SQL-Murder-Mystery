# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Deema Ahmad  
**Date:** April 4, 2026  
**Database:** PostgreSQL (murder_mystery)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|---------------|--------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.73 | 1.83 | -151% (slower) | Yes |
| Q2 — People + license details | 51.20 | 38.11 | **+25.6%** | Partially |
| Q3 — Gym check-ins Jan 9 | 0.70 | 2.09 | -198% (slower) | Yes |
| Q4 — Gold members + income | 4.85 | 8.42 | -73.6% (slower) | Partially |
| Q5 — Facebook events 2018 | 18.20 | 26.16 | -43.7% (slower) | Yes |
| Q6 — Red-haired Tesla drivers | 5.26 | **2.83** | **+46.2%** | Yes (Best) |
| Q7 — Interview keyword search | 29.70 | **17.09** | **+42.5%** | No |
| Q8 — Income by car make | 20.14 | 19.62 | +2.6% | No |

---

## 1. Queries That Improved the Most

- **Q6 (Red-haired Tesla drivers)**: Improved by **46.2%** (from 5.26ms to 2.83ms).  
  The composite index `idx_drivers_hair_car (hair_color, car_make)` was very effective. It allowed a **Bitmap Index Scan** instead of a full table scan.

- **Q7 (Interview keyword search)**: Improved by **42.5%** (from 29.7ms to 17.1ms).  
  Even though we couldn't index the `ILIKE '%...%'` pattern effectively, the overall Join performance improved due to the index on `person`.

- **Q2**: Moderate improvement of **25.6%**. The index on `person(license_id)` helped the Join slightly.

**Best performing index:** `idx_drivers_hair_car` – it targeted a very selective filter perfectly.

---

## 2. Queries That Showed No Improvement or Got Slower

- **Q1 and Q3**: Became slower after adding indexes.  
  Reason: These tables are small (`crime_scene_report` = 1,228 rows, `get_fit_now_check_in` = 2,703 rows). For small tables, the overhead of using an index is often higher than doing a simple Seq Scan.

- **Q4 and Q5**: No real improvement or became slower.  
  The PostgreSQL planner still preferred Seq Scan on the large `person` table in many cases.

- **Q7**: Even though it improved, it still uses **Seq Scan** because of the `ILIKE '%gym%'` and `ILIKE '%murder%'` wildcards. Indexes are generally ineffective when the wildcard `%` is at the beginning.

- **Q8**: Only minor improvement. The heavy Joins and `GROUP BY` limited the benefit of the indexes.

---

## 3. Tradeoffs of Indexing

**Advantages:**
- Significantly faster `SELECT`, `WHERE`, `JOIN`, and `ORDER BY` operations when the right indexes are used (especially on large tables and selective filters).
- Changed full table scans (Seq Scan) to much faster Index Scans in several cases.

**Disadvantages:**
- **Slower writes**: `INSERT`, `UPDATE`, and `DELETE` operations become slower because every index must be updated whenever data changes.
- **Storage overhead**: Each index takes extra disk space.
- **Maintenance cost**: Too many indexes can make the query planner slower and increase overall system complexity.
- **Not always beneficial**: On very small tables, indexes can actually make queries slower.

**Lesson learned:** We should not index every column. Only index columns that are frequently used in `WHERE`, `JOIN`, or `ORDER BY` clauses and on tables large enough to benefit.

---

## 4. Production Recommendation

If this were a real production police database, I would **keep only the most effective indexes** to balance performance and maintenance cost:

### Recommended to Keep:
```sql
CREATE INDEX idx_drivers_hair_car ON drivers_license(hair_color, car_make);
CREATE INDEX idx_person_license   ON person(license_id);
CREATE INDEX idx_person_ssn       ON person(ssn);
CREATE INDEX idx_facebook_date    ON facebook_event_checkin(date);


Recommended to Drop:

idx_checkin_date → small table, no real benefit
idx_member_status → little impact
idx_crime_city_type → table too small
idx_facebook_person → marginal benefit

Justification:
Q6 showed the clearest benefit from indexing, followed by Q7 and Q2. Keeping only 4 well-chosen indexes gives good read performance while minimizing write overhead and storage usage.
In a real system, I would monitor slow queries regularly using EXPLAIN ANALYZE and pg_stat_statements, then adjust or drop indexes accordingly.

Report completed as part of Module 3 Stretch Assignment.