# Performance Report - SQL Murder Mystery Index Investigation

**Student Name:** naef
**Date:** 2026-03-31
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 - Murders in SQL City | 0.09 | 0.10 | +0.01 ms (SCAN->SEARCH; ORDER BY uses index) | `idx_crime_city_type_date` |
| Q2 - People + license details | 0.10 | 0.11 | +0.01 ms (ORDER BY uses index) | `idx_person_name` |
| Q3 - Gym check-ins Jan 9 | 0.11 | 0.11 | ~0.00 ms (SCAN->SEARCH; ORDER BY uses index) | `idx_checkin_date_time` |
| Q4 - Gold members + income | 0.10 | 0.12 | +0.02 ms (indexed membership_status; ORDER BY still sorts) | `idx_member_status_person_id` |
| Q5 - Facebook events 2018 | 0.11 | 0.11 | ~0.00 ms (SCAN->SEARCH; ORDER BY uses index) | `idx_facebook_date_person_id` |
| Q6 - Red-haired Tesla drivers | 0.10 | 0.15 | +0.05 ms (filters via index; ORDER BY still sorts) | `idx_license_hair_color_car_make`, `idx_person_license_id` |
| Q7 - Interview keyword search | 0.10 | 0.11 | +0.01 ms (no plan change; leading wildcard prevents index use) | none |
| Q8 - Income by car make | 0.11 | 0.13 | +0.02 ms (no plan change; GROUP/ORDER still need temp B-trees) | none shown |

---

## 1. Queries That Improved the Most

Q1, Q3, and Q5 have the strongest plan-level improvements: SQLite changes from full scans to indexed searches (`SCAN` -> `SEARCH`) and removes the temp B-tree used for `ORDER BY` in those cases. Q2 also benefits - `idx_person_name` lets SQLite read `person` in `name` order, so the plan no longer needs a separate sort for `ORDER BY p.name`.

---

## 2. Queries That Did NOT Improve

Q7 does not improve because `LIKE '%gym%'` / `LIKE '%murder%'` uses a leading wildcard, so normal B-tree indexes cannot help; SQLite still scans `interview`. Q4 and Q6 still include `USE TEMP B-TREE FOR ORDER BY`, meaning sorting happens after the joins and still needs a temp structure. Q8 also shows little/no improvement: the planner still scans `person` and uses temp B-trees for both `GROUP BY` and `ORDER BY`, so the new indexes weren’t selected for this join order.

---

## 3. Tradeoffs of Indexing

Indexes speed up queries by letting SQLite quickly locate matching rows for `WHERE` and `JOIN` conditions, and sometimes by producing rows in the right order to avoid extra sorting/grouping steps. The downside is write overhead: each `INSERT`/`UPDATE`/`DELETE` must also maintain the index, and every index consumes extra storage. You generally wouldn’t index every column—only the ones used frequently for filtering, joining, and sort/group keys.

---

## 4. Production Recommendation

Keep the indexes that were actually selected by the planner for the biggest plan wins: `idx_crime_city_type_date`, `idx_checkin_date_time`, `idx_member_status_person_id`, `idx_facebook_date_person_id`, `idx_person_name`, and the Q6 pair (`idx_license_hair_color_car_make`, `idx_person_license_id`). Drop indexes that were not used in the `EXPLAIN QUERY PLAN` for this workload (they add write/space overhead without helping these queries), such as `idx_license_car_make`, `idx_interview_person_id`, `idx_person_ssn`, and `idx_checkin_membership_id`.

For Q7 in a production setting, you'd typically use a text-search approach (for example FTS) instead of adding more B-tree indexes, because leading-wildcard `LIKE '%...%'` cannot use standard indexes effectively.

---

*© 2026 LevelUp Economy. All rights reserved.*
