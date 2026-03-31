# Performance Report — SQL Murder Mystery Database

## Overview

This report documents the results of adding indexes to the SQL Murder Mystery database.
Seven indexes were added targeting full table scans identified in the baseline execution plans.
Eight queries were analyzed before and after indexing.

---

## Queries That Improved

### Q1 — Crime Scene Report Filter
- Index added: `idx_crime_city_type ON crime_scene_report(city, type)`
- Before: Full scan of 1,228 rows
- After: Direct index lookup on both filter columns
- Why it helped: Composite index matches both WHERE conditions exactly

### Q3 — Gym Check-in Date Filter
- Index added: `idx_checkin_date ON get_fit_now_check_in(check_in_date)`
- Before: Full scan of 2,703 rows
- After: Index lookup returns only rows for the target date
- Why it helped: Equality filter on a single column is the ideal use case for a B-tree index

### Q4 — Membership Status Filter
- Index added: `idx_member_status ON get_fit_now_member(membership_status)`
- Before: Full scan of 184 rows
- After: Index lookup on membership_status
- Why it helped: Filters to 'gold' members only — practical gain is small due to table size

### Q5 — Facebook Event Date Range
- Index added: `idx_facebook_date ON facebook_event_checkin(date)`
- Before: Full scan of 20,011 rows with temp B-TREE for ORDER BY
- After: Index range scan, ORDER BY eliminated
- Why it helped: Largest table in the database — index on date handles both the WHERE range
  and the ORDER BY in one pass, eliminating the sort step entirely

### Q6 — Red-haired Tesla Drivers
- Indexes added: `idx_license_hair_car ON drivers_license(hair_color, car_make)`
  and `idx_person_license ON person(license_id)`
- Before: Full scan of person (10,011 rows), then PK lookup on drivers_license
- After: Starts from filtered drivers_license rows (few Tesla/red-hair matches),
  then looks up person by license_id using index
- Why it helped: Query optimizer flipped the join order to start from the more
  selective side (drivers_license filter), drastically reducing rows processed

---

## Queries That Did Not Improve

### Q2 — Full Person Join with No Filter
- No improvement despite idx_person_license being available
- Reason: Query retrieves all persons with no WHERE clause — full scan is required
  regardless of indexes since every row must be returned

### Q7 — LIKE Wildcard Search
- No improvement possible
- Reason: LIKE '%gym%' and LIKE '%murder%' use leading wildcards, which prevent
  B-tree index use entirely. SQLite cannot skip to a position in the index when
  the pattern can match anywhere in the string. Full-text search (FTS5) would
  be the correct solution for this type of query in production.

### Q8 — Aggregation Over All Rows
- No improvement despite idx_person_license being available
- Reason: Query aggregates across all persons grouped by car make — every row
  must be read to compute COUNT, AVG, MIN, MAX. Indexes help with filtering
  and lookup but cannot eliminate the need to read all rows for aggregation.

---

## Tradeoffs: Reads vs Writes

Adding indexes improves read performance but introduces costs:

- Write overhead: Every INSERT, UPDATE, or DELETE on an indexed column requires
  updating the index structure in addition to the table. In a write-heavy system
  (e.g., real-time event logging), this overhead compounds.
- Storage: Each index occupies additional disk space proportional to the indexed
  column size and row count. Seven indexes on a 10,000-row database is negligible,
  but the same pattern on a billion-row table would require careful capacity planning.
- Maintenance: Indexes can become fragmented over time and may need rebuilding
  (REINDEX in SQLite) to maintain performance.

---

## Production Recommendation

Indexes to keep in production:

1. `idx_crime_city_type` — Queries filtering by city and type are the primary
   access pattern for this table. High value, low write overhead.

2. `idx_checkin_date` — Check-in lookups by date are a core operational query.
   The table has 2,703 rows and grows with every gym visit.

3. `idx_facebook_date` — Largest table (20,011 rows). Date-range queries are
   common for event analytics. Most impactful index in the set.

4. `idx_facebook_person` — JOIN on person_id is used in most queries touching
   this table. Recommended alongside idx_facebook_date.

5. `idx_person_license` — Used in Q6 and Q8. Worth keeping given how frequently
   person is joined to drivers_license.

6. `idx_license_hair_car` — Useful for investigative queries filtering on physical
   attributes. Low cardinality columns (hair_color, car_make) mean the index is
   most effective when both columns are filtered together.

Index to reconsider:

- `idx_member_status` — get_fit_now_member has only 184 rows. SQLite's query
  planner may prefer a full scan on very small tables regardless of index presence.
  Monitor query plans after data growth before committing to this index.
