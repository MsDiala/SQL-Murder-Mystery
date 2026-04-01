# Performance Report — SQL Murder Mystery Database (PostgreSQL)

## Overview

This report documents the results of adding seven indexes to the SQL Murder Mystery
PostgreSQL database. Eight queries were analyzed using EXPLAIN ANALYZE before and
after indexing to measure the impact on execution plans and query times.

---

## Queries That Improved

### Q1 — Crime Scene Report Filter
- Index added: idx_crime_city_type ON crime_scene_report(city, type)
- Before: Seq Scan 0.324 ms
- After: Index Scan 0.918 ms
- Note: On this small table (1,228 rows) the planner overhead makes the index
  appear slower, but the scan type changed from Seq Scan to Index Scan which
  confirms the index is being used. On a larger table or with more concurrent
  queries this index would show clear improvement.

### Q3 — Gym Check-in Date Filter
- Index added: idx_checkin_date ON get_fit_now_check_in(check_in_date)
- Before: Seq Scan 0.507 ms
- After: Bitmap Index Scan 0.259 ms
- Improvement: 49% faster
- Why it helped: Equality filter on check_in_date is the ideal B-tree use case.
  PostgreSQL used a Bitmap Index Scan to fetch only the 10 matching rows
  instead of scanning all 2,703.

### Q5 — Facebook Event Date Range
- Index added: idx_facebook_date ON facebook_event_checkin(date)
- Before: Seq Scan 13.222 ms
- After: Bitmap Index Scan 12.015 ms
- Improvement: 9% faster
- Why it helped: Date range filter on the largest table (20,011 rows) now uses
  a Bitmap Index Scan. The improvement is modest because 5,025 rows match the
  range -- roughly 25% of the table -- which reduces the index benefit.

### Q6 — Red-haired Tesla Drivers
- Indexes added: idx_license_hair_car ON drivers_license(hair_color, car_make)
  and idx_person_license ON person(license_id)
- Before: Hash Join with Seq Scan on both tables, 5.183 ms
- After: Nested Loop with Bitmap Index Scan + Index Scan, 0.445 ms
- Improvement: 91% faster (best improvement in the set)
- Why it helped: The composite index on drivers_license filters down to only 4
  matching rows. PostgreSQL switched from Hash Join to Nested Loop because the
  result set is tiny. The idx_person_license index then handles the join lookup
  efficiently. This is the clearest example of how selective indexes eliminate
  the majority of work.

---

## Queries That Did Not Improve

### Q2 — Full Person Join with No Filter
- No improvement despite idx_person_license being available
- Reason: Query retrieves all persons with no WHERE clause. Every row must be
  returned so a full scan is unavoidable. The index cannot help when selectivity
  is 100%.

### Q4 — Gold Gym Members
- Marginal improvement only (2.784 ms to 2.714 ms)
- Reason: get_fit_now_member has only 184 rows. PostgreSQL correctly chose a
  Seq Scan over the idx_member_status index because scanning 184 rows is faster
  than the overhead of an index lookup on such a small table.

### Q7 — ILIKE Wildcard Search
- No improvement possible
- Reason: ILIKE '%gym%' and ILIKE '%murder%' use leading wildcards. PostgreSQL
  cannot use a B-tree index when the pattern can match anywhere in the string.
  The only solution for this type of query in production is full-text search
  using PostgreSQL's tsvector/tsquery or pg_trgm extension for trigram indexes.

### Q8 — Aggregation Over All Rows
- Partial improvement (22.635 ms to 17.617 ms)
- Reason: The query must read every row to compute COUNT, AVG, MIN, MAX grouped
  by car_make. Full scans on person, income, and drivers_license are unavoidable.
  The improvement seen is likely from join reordering using idx_person_license.

---

## Tradeoffs: Reads vs Writes

Adding indexes improves read performance but introduces costs:

Write overhead: Every INSERT, UPDATE, or DELETE on an indexed column requires
updating the index structure in addition to the table. In a write-heavy system
such as real-time event logging or high-frequency transactions, this overhead
compounds significantly. For the facebook_event_checkin table which receives
continuous inserts, the idx_facebook_date and idx_facebook_person indexes add
maintenance cost on every new check-in record.

Storage: Each index occupies additional disk space. Seven indexes on tables
ranging from 184 to 20,011 rows adds modest overhead here, but the same
indexing strategy applied to a billion-row table would require careful capacity
planning and monitoring.

Query planner overhead: PostgreSQL must evaluate whether to use an index for
every query. On very small tables (get_fit_now_member, crime_scene_report) the
planner may correctly choose a seq scan even when an index exists, as seen in
Q1 and Q4.

---

## Production Recommendation

Indexes to keep:

1. idx_crime_city_type -- Primary access pattern for crime investigation queries.
   Structurally correct even if overhead masks benefit on small table.

2. idx_checkin_date -- 49% improvement on a frequently queried operational table.
   Gym check-in lookups by date are a core use case.

3. idx_facebook_date -- Largest table in the database. Date range queries are
   the primary access pattern. Keep alongside idx_facebook_person.

4. idx_facebook_person -- JOIN on person_id is used in most queries touching
   this table. Essential companion to idx_facebook_date.

5. idx_person_license -- Used in Q6 and contributed to Q8 improvement.
   person is joined to drivers_license in multiple queries.

6. idx_license_hair_car -- Produced the best single improvement (91% on Q6).
   Investigative queries filtering on physical attributes are common in this
   database. Highly selective composite index with low maintenance cost.

Index to reconsider:

- idx_member_status -- get_fit_now_member has only 184 rows. PostgreSQL chose
  Seq Scan over this index in Q4 which is the correct decision. Monitor whether
  this index ever gets used as the table grows before committing to it long-term.