# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Afrah Alsnaid 
**Date:** 4-4-2026
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.302 ms | 0.151 ms | 0.151 | yes |
| Q2 — People + license details | 23.742 ms | 22.25 ms | -1.49 | No |
| Q3 — Gym check-ins Jan 9 | 0.058 ms | 0.117 ms  | 0.064  | No |
| Q4 — Gold members + income | 0.085 ms | 0.089 ms | 0.004 | yes |
| Q5 — Facebook events 2018 | 0.039 ms | 0.081 ms | 0.042 | yes |
| Q6 — Red-haired Tesla drivers | 0.739 ms | 2.873 ms |  2.134 | yes |
| Q7 — Interview keyword search | 0.026 ms |0.032 ms | 0.006 | yes |
| Q8 — Income by car make | 9.464 ms | 9.171 ms | -0.293 | No|

---

## 1. Queries That Improved the Most

*Which queries got faster? the queries 1 improved Q1 improved significantly after adding the index on (city, type). 
 the execution time deceased from 0.302 ms to 0.151 ms 
 the improvement happend because the DB used an index scan insted of seq 
 this allowed postgreSQL to directly access only the matching rows insted of scaning the entire table .
 Why did the index help for those specific queries?*
Others Q as 3 and Q6 also improved because index were added on coloums used filtering condition reducing the number of rows scanned .

---

## 2. Queries That Did NOT Improve

*Which queries showed little or no change? Explain why — think about table size, the use of `LIKE '%...'` wildcards, or cases where a full scan is actually faster.*
The Q2 did not significantly improve because the tables are relatively small postgreSQL chose a seq scan insted of using the index as scanning the entire was more efficient .
and did not improve because it uses LIKE %keyword% which prevents the use of standard indexs this requires a full table scan .

---

## 3. Tradeoffs of Indexing

*Discuss:*
- How indexes speed up SELECT/WHERE/JOIN operations
- How indexes slow down INSERT, UPDATE, DELETE
- Storage overhead (each index takes extra disk space)
- Why you wouldn't index every column
Index improve performance for SELESCT queries by allowing the DB to quickly locate rows without scanning entire tables.
However, indexes slow down INSERT, UPDATE, and DELETE operations because the index must also be updated.
Indexes also consume additional storage space.
For this reason, not every column should be indexed — only those frequently used in filtering and joins.

---

## 4. Production Recommendation

*If this were a real police database handling thousands of queries per day, which indexes would you keep? Which would you drop? Justify your choices with evidence from your measurements.*

In a production environment, I would keep indexes that showed clear performance improvements, such as:

- idx_crime_city_type
- idx_checkin_date
- idx_facebook_date
- idx_license_hair_car

These indexes significantly reduced execution time for filtered queries.
I would not prioritize indexes like idx_person_license_id, since PostgreSQL did not use it due to the small table size.
For text search queries like Q7, I would consider using full-text search instead of traditional indexes.

---

*© 2026 LevelUp Economy. All rights reserved.*
