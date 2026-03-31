# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Rand Jamil  
**Date:** March 31, 2026  
**Database:** `murder_mystery` (PostgreSQL)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------:|-------------:|-------------|-------------|
| Q1 — Murders in SQL City | 0.500 | 0.480 | Small timing improvement, major plan improvement | Yes |
| Q2 — People + license details | 17.644 | 13.723 | Moderate timing improvement | No |
| Q3 — Gym check-ins Jan 9 | 0.089 | 0.109 | No improvement | No |
| Q4 — Gold members + income | 0.082 | 0.109 | No improvement | Partially |
| Q5 — Facebook events 2018 | 0.276 | 0.037 | Timing improved, plan unchanged | No |
| Q6 — Red-haired Tesla drivers | 2.339 | 5.476 | Slower timing, better access plan | Yes |
| Q7 — Interview keyword search | 0.075 | 0.023 | Small timing improvement, plan unchanged | No |
| Q8 — Income by car make | 10.161 | 9.635 | Small timing improvement | No |

---

## 1. Queries That Improved the Most

The query that improved the most in terms of execution plan was **Q1 — Murders in SQL City**.  
Before indexing, PostgreSQL used a **Seq Scan** on `crime_scene_report` and had to filter many rows to find the 3 matching results. After indexing, it used `idx_crime_city_type` with an **Index Scan**. This helped because the query filters directly on `city` and `type`, so the composite index matched the `WHERE` clause very well.

Another important improvement was **Q6 — Red-haired Tesla drivers**.  
Before indexing, PostgreSQL used a **Seq Scan** on `drivers_license` and removed 10003 rows by filter. After indexing, it used:
- `Bitmap Index Scan` on `idx_dl_hair_make`
- `Bitmap Heap Scan` on `drivers_license`
- `Index Scan` on `person` using `idx_person_license`

This is a strong structural improvement because the database stopped scanning the full filtered table and used indexes for both filtering and joining. Even though the execution time became slower in this small dataset, the access pattern became more efficient and scalable.

**Q2 — People + license details** also became faster in timing, from **17.644 ms** to **13.723 ms**, but the execution plan stayed the same. PostgreSQL still used sequential scans and a hash join. This means the indexes did not change the join strategy, but the query still ran a bit faster.

---

## 2. Queries That Did NOT Improve

**Q3 — Gym check-ins Jan 9** showed no meaningful improvement.  
The query returned **0 rows**, so PostgreSQL did not have much work to do. Because of that, the benefit of the index on `check_in_date` did not appear clearly in this dataset.

**Q4 — Gold members + income** also showed no real improvement.  
This query returned **0 rows**, so the database stopped early. Although `idx_income_ssn` was available, it was not meaningfully used because there were no matching gold members to continue the join.

**Q5 — Facebook events 2018** had a lower execution time, but the plan still used a **Seq Scan** on `facebook_event_checkin`.  
So the time improved, but the access method did not. Since the query returned **0 rows**, PostgreSQL still chose a sequential scan.

**Q7 — Interview keyword search** did not improve in plan.  
It still used a **Seq Scan** on `interview` because the query uses:
- `LIKE '%gym%'`
- `LIKE '%murder%'`

These are leading-wildcard searches, and normal B-tree indexes usually do not help with this pattern. This is a common case where a full scan is still used.

**Q8 — Income by car make** showed only a small improvement in timing, from **10.161 ms** to **9.635 ms**.  
The plan remained mostly the same with:
- `Seq Scan`
- `Hash Join`
- `HashAggregate`

This happened because the query reads large parts of multiple tables and performs grouping and aggregation, so indexing gives limited benefit.

---

## 3. Tradeoffs of Indexing

Indexes help queries run faster when the database needs to:
- filter rows in `WHERE`
- match rows in `JOIN`
- find exact values quickly

This is why indexes are often very useful for selective lookups and foreign-key style joins.

However, indexes also have costs:
- they use extra disk space
- they make `INSERT`, `UPDATE`, and `DELETE` slower
- PostgreSQL must keep the indexes updated whenever the table data changes

Because of that, it is not a good idea to index every column. Some indexes may never be used, and too many indexes create overhead without real benefit. Good indexing should be based on actual query patterns and measurements.

---

## 4. Production Recommendation

If this were a real police database with many daily queries, I would keep the indexes that support common filtering and joins and that showed clear or reasonable value:

- `idx_crime_city_type` on `crime_scene_report(city, type)`
- `idx_person_license` on `person(license_id)`
- `idx_dl_hair_make` on `drivers_license(hair_color, car_make)`
- `idx_income_ssn` on `income(ssn)`
- `idx_person_ssn` on `person(ssn)`

I would also consider keeping:
- `idx_facebook_person` on `facebook_event_checkin(person_id)`

I would be less certain about keeping these based only on this dataset:
- `idx_checkin_date`
- `idx_facebook_date`
- `idx_member_status`

The reason is that the related queries returned 0 rows, so their benefit was not clearly shown in the measurements.

I would not rely on a normal B-tree index for the interview text search query with `LIKE '%...%'`. If that search were important in production, I would use a full-text search solution instead.

Overall, I would keep the indexes that help selective filters and joins, and avoid keeping indexes that add write cost without strong evidence of benefit.

---

*© 2026 LevelUp Economy. All rights reserved.*