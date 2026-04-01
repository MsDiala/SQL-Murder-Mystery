# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** ___
**Date:** ___
**Database:** `murder_mystery` (PostgreSQL)

---

## Summary Table

| Query                         | Baseline (ms) | Indexed (ms) | Improvement | Index Used?                                   |
| ----------------------------- | ------------: | -----------: | ----------: | --------------------------------------------- |
| Q1 — Murders in SQL City      |         0.138 |        0.170 |   -0.032 ms | Yes — `idx_crime_city_type`                   |
| Q2 — People + license details |        21.441 |       26.052 |   -4.611 ms | No                                            |
| Q3 — Gym check-ins Jan 9      |         1.098 |        0.147 |   +0.951 ms | Yes — `idx_checkin_date`                      |
| Q4 — Gold members + income    |         1.256 | Not captured |         N/A | Not confirmed                                 |
| Q5 — Facebook events 2018     |         6.159 |        5.711 |   +0.448 ms | Yes — `idx_facebook_date`                     |
| Q6 — Red-haired Tesla drivers |         0.939 |        0.078 |   +0.861 ms | Yes — `idx_dl_hair_car`, `idx_person_license` |
| Q7 — Interview keyword search |         7.063 |        7.063 |    0.000 ms | No                                            |
| Q8 — Income by car make       |        14.359 | Not captured |         N/A | Not confirmed                                 |

> Positive improvement means the indexed version was faster. Negative improvement means the indexed run was slightly slower.

---

## 1. Queries That Improved the Most

The biggest improvement came from **Q3**, which queried gym check-ins for a specific date. Before indexing, PostgreSQL used a sequential scan on `get_fit_now_check_in` and filtered out 2693 rows to return only 10 matching rows. After creating `idx_checkin_date`, the query changed to a `Bitmap Index Scan` followed by a `Bitmap Heap Scan`, and execution time dropped from **1.098 ms** to **0.147 ms**.

Another strong improvement appeared in **Q6**, which filtered `drivers_license` by `hair_color = 'red'` and `car_make = 'Tesla'`. Before indexing, PostgreSQL scanned nearly the whole table and filtered out 10003 rows. After adding the composite index `idx_dl_hair_car` and using `idx_person_license` for the join, execution time dropped from **0.939 ms** to **0.078 ms**. This was a strong example of how composite indexes help when a query filters on multiple columns together.

**Q5** also improved. The query filtered Facebook event check-ins by a date range, and after adding `idx_facebook_date`, PostgreSQL switched from a sequential scan to a bitmap index scan on `facebook_event_checkin`. Execution time improved from **6.159 ms** to **5.711 ms**.

**Q1** changed from a sequential scan to an index scan after adding `idx_crime_city_type`, which shows that the planner recognized the index as useful. However, the execution time was slightly slower, from **0.138 ms** to **0.170 ms**, because the table is very small and the index overhead outweighed any benefit.

---

## 2. Queries That Did NOT Improve

**Q2** did not improve. Even after creating `idx_person_license`, PostgreSQL still chose a `Hash Join` with sequential scans on both `person` and `drivers_license`. This query has no `WHERE` clause and returns a large portion of both tables, so scanning the tables directly is reasonable. In fact, the indexed run was slightly slower: **21.441 ms** to **26.052 ms**.

**Q7** also did not improve. The query searches interview transcripts using:

```sql
ILIKE '%gym%' OR ILIKE '%murder%'
```

This pattern starts with a wildcard, so a normal B-tree index cannot be used efficiently. PostgreSQL therefore kept the sequential scan on `interview`, and execution time stayed essentially unchanged at **7.063 ms**.

**Q4** likely would not improve much even with an index on `membership_status`, because `get_fit_now_member` is a very small table with only 184 rows. In small tables, sequential scan is often already optimal.

**Q8** may also show limited improvement because it is an aggregation-heavy query with joins and `GROUP BY`. Even when indexes exist on join columns, PostgreSQL may still prefer hash joins and full scans if it needs to process a large share of the data.

---

## 3. Tradeoffs of Indexing

Indexes improve query performance by reducing the amount of data the database must scan. They are especially useful for `WHERE` filters, join conditions, and range lookups. In this investigation, indexes clearly helped queries like Q3, Q5, and Q6 by changing the plan from sequential scans to index-based access paths.

However, indexes are not free. Every index adds overhead to `INSERT`, `UPDATE`, and `DELETE` operations because PostgreSQL must keep the index updated whenever table data changes. Indexes also consume additional disk space, especially on large tables or when multiple indexes are created on the same table.

For this reason, it is usually a mistake to index every column. Some queries do not benefit from indexes at all, especially when they return most of a table, use leading wildcards, or work with very small tables. Q2 and Q7 are good examples of cases where extra indexing provided little or no value.

---

## 4. Production Recommendation

If this were a real production database, I would definitely keep the indexes that showed clear practical value:

* `idx_checkin_date` on `get_fit_now_check_in(check_in_date)` because it significantly improved Q3.
* `idx_facebook_date` on `facebook_event_checkin(date)` because it improved date-range filtering in Q5.
* `idx_dl_hair_car` on `drivers_license(hair_color, car_make)` because it strongly improved Q6.
* `idx_person_license` on `person(license_id)` because it supports joins from `person` to `drivers_license`, and it was useful in Q6.

I would also keep `idx_crime_city_type` if similar filtered searches on crime reports are common, even though Q1 did not become faster in this small dataset. The execution plan improved, and the index would likely matter more as the table grows.

I would be less confident about keeping `idx_member_status` because the underlying table is very small, so the benefit is limited. I would also avoid relying on normal B-tree indexing for transcript searches like Q7, because wildcard text searches need a different approach such as full-text search or trigram indexing.

For `idx_person_ssn` and `idx_income_ssn`, I would evaluate them based on additional workloads before deciding. They may help join-heavy analytics like Q8, but the evidence captured here was incomplete because the post-index execution plan was not re-run and measured.

Overall, the best production strategy is to keep indexes that consistently improve selective filters and common joins, and avoid indexes that do not change the plan or only help tiny tables.

---

*© 2026 LevelUp Economy. All rights reserved.*
