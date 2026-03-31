# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Shahd Ghunimah
**Date:** 31/3/2026 
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|------|---------------|--------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.01 | 0.009 | Improved | Yes |
| Q2 — People + license details | 0.004 | 0.004 | No change | Partial |
| Q3 — Gym check-ins Jan 9 | 0.01 | 0.006 | Improved | Yes |
| Q4 — Gold members + income | 0.01 | 0.003 | Improved | Yes |
| Q5 — Facebook events 2018 | 0.02 | 0.02 | Improved | Yes |
| Q6 — Red-haired Tesla drivers | 0.04 | 0.04 | Strong improvement | Yes |
| Q7 — Interview keyword search | 0.015 | 0.015 | No change | No |
| Q8 — Income by car make | 0.035 | 0.035 | No change | Partial |

---

## 1. Queries That Improved the Most

The queries that showed the most improvement were Q1, Q3, Q4, Q5, and Q6.

- **Q1** improved because an index on `(city, type)` allowed SQLite to filter rows directly instead of scanning the entire table.
- **Q3** improved significantly after indexing `check_in_date`, allowing efficient filtering instead of scanning all check-ins.
- **Q4** benefited from indexing `membership_status`, which reduced the number of rows processed.
- **Q5** improved using an index on `facebook_event_checkin(date)`, enabling efficient range filtering.
- **Q6** showed strong improvement due to a composite index on `(hair_color, car_make)`, allowing SQLite to directly locate matching rows instead of scanning.

These improvements occurred because indexes reduce the number of rows SQLite must examine, converting full table scans into targeted index lookups.

---

## 2. Queries That Did NOT Improve

The queries that showed little or no improvement were Q2, Q7, and Q8.

- **Q2** still performed a full scan on the `person` table. Even with an index on `license_id`, SQLite chose a scan due to query structure and optimizer decisions.
- **Q7** did not improve because it uses `LIKE '%keyword%'`. Since the wildcard appears at the beginning, standard indexes cannot be used effectively.
- **Q8** still scans the `person` table and requires temporary B-Trees for both grouping and sorting, making it expensive despite indexes.

In these cases, indexing either does not apply or does not significantly change the execution plan.

---

## 3. Tradeoffs of Indexing

Indexes provide several benefits:

- They speed up `SELECT`, `WHERE`, and `JOIN` operations by allowing direct access to rows.
- They reduce full table scans, especially for large datasets.

However, indexes also have drawbacks:

- They slow down `INSERT`, `UPDATE`, and `DELETE` operations because indexes must be updated.
- They require additional disk space.
- Not all queries benefit from indexes (e.g., wildcard searches or small tables).

Because of these tradeoffs, it is not efficient to index every column.

---

## 4. Production Recommendation

If this were a real production system, I would keep the following indexes:

- `crime_scene_report(city, type)`
- `get_fit_now_check_in(check_in_date)`
- `get_fit_now_member(membership_status)`
- `facebook_event_checkin(date)`
- `drivers_license(hair_color, car_make)`
- `person(license_id)`

These indexes provided clear performance improvements and are useful for common filtering and join operations.

I would consider dropping or avoiding:

- Indexes on columns used in wildcard searches (e.g., interview transcripts)
- Indexes that did not significantly change execution plans (e.g., some joins in Q2 and Q8)

The final strategy is to keep only indexes that provide measurable performance benefits.

---

*© 2026 LevelUp Economy. All rights reserved.*