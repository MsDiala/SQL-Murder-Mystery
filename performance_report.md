# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:**Luma Muin Alazzeh
**Date:** 31/3/2025
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.301 | 0.18 | 40.19 | YES |
| Q2 — People + license details | 29.829 | 21.792 | 26.94 | YES |
| Q3 — Gym check-ins Jan 9 | 0.335 | 0.232 | 30.68 | YES |
| Q4 — Gold members + income | 0.45 | 0.503 | -11.88 | YES |
| Q5 — Facebook events 2018 | 9.668 | 11.257 | -16.44 | YES |
| Q6 — Red-haired Tesla drivers| 2.558 | 0.195 | 92.39 | YES |
| Q7 — Interview keyword search | 1.309 | 1.797 | -37.32 | NO |
| Q8 — Income by car make | 14.166 | 10.212 | 27.91 | NO |

---

## 1. Queries That Improved the Most

*Which queries got faster? By how much? Why did the index help for those specific queries?*
Q6 — Red-haired Tesla drivers: This query saw a massive 92.39% improvement (from 2.558ms to 0.195ms). This is because the query likely filters on highly specific attributes (high cardinality). An index allows the database engine to jump directly to the few rows matching "Tesla" and "Red," rather than scanning the entire drivers_license table.

Q1 — Murders in SQL City: Improved by 40.19%. Since this query targets a specific city and event type, the index allows the engine to bypass all other crime reports in the database, significantly reducing the I/O needed to find the relevant rows.

---

## 2. Queries That Did NOT Improve

*Which queries showed little or no change? Explain why — think about table size, the use of `LIKE '%...'` wildcards, or cases where a full scan is actually faster.*
Q7 — Interview keyword search: This query actually slowed down (-37.32%). Standard B-Tree indexes are ineffective for LIKE '%keyword%' queries because the wildcard at the beginning prevents the engine from "sorting" or "seeking" the data. The engine must perform a full scan anyway, and the overhead of checking the index actually adds latency.

Q4 & Q5: These showed negative improvements (around -12% to -16%). This often happens when the number of returned rows is a large percentage of the total table. In these cases, the database decides it’s actually faster to read the table sequentially (Full Table Scan) than to jump back and forth between the index and the data storage (Bookmark Lookup).

---

## 3. Tradeoffs of Indexing

*Discuss:*
- How indexes speed up SELECT/WHERE/JOIN operations
- How indexes slow down INSERT, UPDATE, DELETE
- Storage overhead (each index takes extra disk space)
- Why you wouldn't index every column
Speed vs. Storage: While indexes make SELECT, WHERE, and JOIN operations much faster, they act like a "hidden table" that consumes extra disk space.

Write Penalty: Every time you run an INSERT, UPDATE, or DELETE, the database must also update the index. In a high-traffic system, too many indexes can significantly bottleneck data entry.

Maintenance: Over time, indexes can become fragmented, requiring "Rebuild" or "Reorganize" operations to maintain their efficiency.

The "Every Column" Myth: Indexing every column is counterproductive. It confuses the Query Optimizer and bloats the database size without providing meaningful speed gains for most real-world queries.
---

## 4. Production Recommendation

*If this were a real police database handling thousands of queries per day, which indexes would you keep? Which would you drop? Justify your choices with evidence from your measurements.*
Keep the indexes for Q1, Q2, and Q6: These represent "lookup" queries (searching by name, plate number, or specific physical traits). In a database with millions of citizens, these would be the most frequent and critical searches for investigators.

Drop the index for Q7: It provides no benefit for keyword searching. Instead, I would recommend implementing Full-Text Search (FTS5) for the interview table to handle transcript searches efficiently.

Drop the index for Q4: The data suggests that the engine prefers a full scan for income/membership distributions. This saves storage space and improves write speeds for the income and members tables.

Monitor Q8: While it showed a 27.91% improvement, it wasn't used by the index according to your "Index Used?" column. This suggests the improvement might be due to system caching rather than the index itself. I would re-test this before committing it to production.
---

*© 2026 LevelUp Economy. All rights reserved.*
