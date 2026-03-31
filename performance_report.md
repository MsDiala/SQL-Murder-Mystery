# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Hadeel Banihani
**Date:** 31/3/2026
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

=== Summary Table ===
| Query | Baseline (ms) | Indexed (ms) | Improvement (%) | Index Used? |
|-------|---------------|-------------|----------------|-------------|
| Q1 — Murders in SQL City | 0.363 | 0.108 | 70.39 | YES |
| Q2 — People + license details | 24.818 | 18.234 | 26.53 | YES |
| Q3 — Gym members checked in Jan 9 | 0.231 | 0.188 | 18.6 | YES |
| Q4 — Gold members and income | 0.349 | 0.243 | 30.28 | YES |
| Q5 — Facebook events 2018 | 6.694 | 5.965 | 10.89 | YES |
| Q6 — Red-haired Tesla drivers | 1.319 | 0.144 | 89.08 | YES |
| Q7 — Interview keyword search | 1.261 | 0.922 | 26.86 | NO |
| Q8 — Average income by car make | 6.63 | 5.983 | 9.76 | NO |
---

## 1. Queries That Improved the Most

*Which queries got faster? By how much? Why did the index help for those specific queries?*

The queries that showed the most improvement were:
Q6 — Red-haired Tesla drivers (89.08%)
Q1 — Murders in SQL City (70.39%)

These queries improved significantly because they rely on filtering conditions (WHERE) on indexed columns. Indexes allow the database to quickly locate matching rows instead of scanning the entire table.

For example, in Q6, filtering by attributes like hair color and car make benefits greatly from indexing, as these columns are directly used in search conditions.

---

## 2. Queries That Did NOT Improve

*Which queries showed little or no change? Explain why — think about table size, the use of `LIKE '%...'` wildcards, or cases where a full scan is actually faster.*

The queries that showed little or no improvement were:

Q7 — Interview keyword search
Q8 — Income by car make
Q5 — Facebook events (minor improvement)

Reasons:

Q7 likely uses LIKE '%keyword%', which prevents index usage because the wildcard at the beginning forces a full table scan.
Q8 involves aggregation (GROUP BY), where indexes have limited impact because the database still needs to process many rows.
Q5 operates on a relatively small dataset or conditions where scanning is already efficient.

---

## 3. Tradeoffs of Indexing

*Discuss:*
- How indexes speed up SELECT/WHERE/JOIN operations
- How indexes slow down INSERT, UPDATE, DELETE
- Storage overhead (each index takes extra disk space)
- Why you wouldn't index every column

---
Indexes provide important performance benefits, but they also come with tradeoffs.

Benefits:

Indexes speed up SELECT, WHERE, and JOIN operations by allowing the database to quickly locate the required rows instead of scanning the entire table. This is especially useful for large datasets and frequently queried columns.

Drawbacks:

Indexes can slow down INSERT, UPDATE, and DELETE operations because the database must also update the index whenever the data changes, which adds extra processing time.

Indexes also require additional storage space, as each index is stored separately from the table data.

Why not index every column?

Not all columns benefit from indexing. Creating too many indexes can reduce overall performance and increase maintenance cost. Some queries, such as those using LIKE '%value%' or heavy aggregations, may not benefit from indexes at all.

Conclusion:

Indexes should be used selectively on columns that are frequently used in filtering, joining, or sorting, based on actual query patterns.

## 4. Production Recommendation

*If this were a real police database handling thousands of queries per day, which indexes would you keep? Which would you drop? Justify your choices with evidence from your measurements.*

---
If this were a real production system handling thousands of queries per day, I would keep indexes on columns that showed clear and significant performance improvement.

Indexes to keep:

I would keep indexes used in queries such as:

Q6 — Red-haired Tesla drivers (89.08% improvement)
Q1 — Murders in SQL City (70.39% improvement)
Q4 — Gold members + income (30.28% improvement)

These queries demonstrated strong performance gains because they rely on filtering and joins on indexed columns. This indicates that the indexes are effectively reducing execution time.

Indexes to reconsider or drop:

I would consider dropping or avoiding indexes for queries such as:

Q7 — Interview keyword search
Q8 — Income by car make
Q5 — Facebook events (minimal improvement)

These queries showed limited improvement or did not use indexes effectively. In particular, queries using patterns like LIKE '%value%' or heavy aggregations tend not to benefit from indexing.

Justification:

Indexes should be maintained where they provide measurable performance benefits. Since indexes increase storage usage and slow down write operations, it is important to keep only those that significantly improve query performance.

Conclusion:

In a production environment, indexing decisions should be driven by actual query performance metrics. High-impact queries should be optimized with indexes, while low-impact or unused indexes should be removed to maintain system efficiency.


*© 2026 LevelUp Economy. All rights reserved.*
