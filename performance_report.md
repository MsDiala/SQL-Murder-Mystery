# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Hosam Alkhawaldeh
**Date:** 2026-04-01  
**Database:** PostgreSQL (murder_mystery)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | 1.927 | 0.535 | ~72% faster | Yes |
| Q2 — People + license details | 28.063 | 38.651 | Slower | No |
| Q3 — Gym check-ins Jan 9 | 0.475 | 0.064 | Faster | No (Seq Scan) |
| Q4 — Gold members + income | 0.041 | 0.068 | Similar | Partial |
| Q5 — Facebook events 2018 | 0.034 | 0.117 | Slightly slower | No |
| Q6 — Red-haired Tesla drivers | 9.221 | 6.059 | Improved | Partial |
| Q7 — Interview keyword search | 0.094 | 0.040 | Minimal | No |
| Q8 — Income by car make | 15.837 | 17.409 | Slower | No |

---

## 1. Queries That Improved the Most

The queries that improved the most were Q1 and Q6.

Q1 showed a significant improvement (~72%) after adding a composite index on (city, type). Initially, PostgreSQL performed a sequential scan and filtered out most rows. After indexing, it used an Index Scan to directly retrieve the matching rows, greatly reducing execution time.

Q6 also improved after indexing. Although PostgreSQL still performed a sequential scan on the drivers_license table, it used an index (idx_person_license) on the person table for the join. This reduced the cost of joining and improved overall performance.

Q3 also became faster, but not due to index usage. PostgreSQL chose a sequential scan because the table is very small, making it more efficient than using an index.

---

## 2. Queries That Did NOT Improve

Several queries showed little or no improvement, and some even became slower:

Q2 became slower after indexing. This is because the query processes a large number of rows and uses a Hash Join. PostgreSQL determined that a sequential scan was more efficient than using the index.

Q5 also showed slightly worse performance. The table is small, and PostgreSQL chose a sequential scan instead of using the index.

Q8 became slower due to heavy aggregation (GROUP BY and AVG). Indexes are less helpful in aggregation queries where most rows must still be processed.

Q7 did not benefit from indexing because it uses:
ILIKE '%keyword%'

B-tree indexes cannot be used when a wildcard (%) appears at the beginning of the pattern, so PostgreSQL must perform a sequential scan.

---

## 3. Tradeoffs of Indexing

Indexes improve performance for SELECT queries, especially those involving filtering (WHERE), joins (JOIN), and sorting (ORDER BY).

However, indexes come with important tradeoffs:

- INSERT, UPDATE, and DELETE operations become slower because indexes must be updated.
- Indexes consume additional disk space.
- Too many indexes can negatively impact overall system performance.

Therefore, indexes should only be created when they provide measurable performance benefits.

---

## 4. Production Recommendation

Based on the results, the following indexes should be kept in a production system:

- idx_crime_city_type → significantly improves filtering performance (Q1)
- idx_person_license → improves join performance (Q6)
- idx_checkin_date → useful for date-based filtering (Q3 scenarios)
- idx_facebook_person → useful for joins
- idx_person_ssn and idx_income_ssn → important for join operations

The following indexes may be reconsidered:

- idx_facebook_date → not used effectively due to small table size
- idx_dl_car_make → limited benefit for aggregation queries

Additionally, for text search queries like Q7, a full-text search index (e.g., GIN index) would be more appropriate than a standard B-tree index.

---

## Conclusion

The results demonstrate that indexing can significantly improve query performance when applied correctly, especially for filtering and join operations.

However, not all queries benefit from indexes. PostgreSQL may still choose sequential scans when they are more efficient, particularly for small tables or complex aggregations.

Effective performance optimization requires analyzing execution plans and making data-driven decisions rather than assuming indexes will always help.
*© 2026 LevelUp Economy. All rights reserved.*
