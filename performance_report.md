# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Rama Mathloni
**Date:** March 31, 2026
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | 7.501 | 1.322 | ~82% Faster | Yes (`idx_crime_city_type`) |
| Q2 — People + license details | 59.571 | 66.561 | No change | No (Scanning `p`) |
| Q3 — Gym check-ins Jan 9 | 1.972 | 1.919 | Minimal | Yes (`idx_checkin_date`) |
| Q4 — Gold members + income | 1.803 | 1.024 | ~43% Faster | Yes (`idx_member_status`) |
| Q5 — Facebook events 2018 | 19.991 | 20.957 | Stable | Yes (`idx_facebook_date`) |
| Q6 — Red-haired Tesla drivers | 7.828 | 1.003 | ~87% Faster | Yes (`idx_license_hair_car`) |
| Q7 — Interview keyword search | 2.724 | 2.984 | No change | No (Full Scan on `i`) |
| Q8 — Income by car make | 16.980 | 18.328 | No change | No (Full Scan on `p`) |

---

## 1. Queries That Improved the Most

* **Q6 (Red-haired Tesla drivers):** Improved by over 85%. The composite index `idx_license_hair_car` allowed the engine to pinpoint records matching both criteria instantly, avoiding a full scan of the `person` table.
* **Q1 (Murders in SQL City):** Improved significantly because `idx_crime_city_type` eliminated the need to read every row in the `crime_scene_report` table to find specific cities and types.

---

## 2. Queries That Did NOT Improve

* **Q7 (Interview keyword search):** Showed no improvement because it uses `LIKE '%gym%'`. B-Tree indexes cannot optimize searches where the wildcard `%` is at the beginning of the string.
* **Q2 & Q8:** These queries still start with a `SCAN` on the `person` table. Even with indexes on joining columns, the database chose to scan the base table to fulfill the `ORDER BY` or `GROUP BY` requirements.

---

## 3. Tradeoffs of Indexing

* **Speed:** Indexes significantly speed up `SELECT` and `JOIN` operations by providing a direct pointer to data, turning $O(N)$ scans into $O(\log N)$ searches.
* **Write Performance:** Every `INSERT`, `UPDATE`, or `DELETE` now takes longer because the database must maintain and rewrite the B-Tree structures for each index.
* **Storage:** Each index adds to the disk space footprint of the `.db` file.
* **Selectivity:** Indexing columns with very few unique values (like "Gender") is often useless as a full scan might still be more efficient for the engine.

---

## 4. Production Recommendation

Based on the evidence:
* **Keep:** `idx_person_license_id` and `idx_license_hair_car` because they provide massive speed gains for person/license lookups which are frequent in police work.
* **Keep:** `idx_facebook_date` and `idx_checkin_date` because event logs grow rapidly, and filtering by date is a primary use case.
* **Drop:** Any index on the `interview` table for `LIKE` searches, as it provides zero performance gain for the storage it consumes. Full-text search (FTS) would be a better production alternative here.

---

*© 2026 LevelUp Economy. All rights reserved.*