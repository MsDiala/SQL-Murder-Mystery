# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Jumana Melhem
**Date:** 4/4/2026
**Database:** `murder_mystery` (PostgreSQL via Docker)
> *Note: Adjusted from SQLite to reflect the provided Docker environment.*


---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City |0.85 | 0.15 | -0.70 ms | Yes|
| Q2 — People + license details |12.50 | 6.20 | -6.30 ms | Yes|
| Q3 — Gym check-ins Jan 9 |1.20 | 0.88 | -0.32 ms | Yes|
| Q4 — Gold members + income | 5.40 | 0.80 | -4.60 ms | Yes |
| Q5 — Facebook events 2018 | 18.30 | 3.10 | -15.20 ms | Yes |
| Q6 — Red-haired Tesla drivers |4.10 | 0.20 | -3.90 ms | Yes|
| Q7 — Interview keyword search |3.50 | 3.50 | 0.00 ms | No|
| Q8 — Income by car make | 22.10 | 8.50 | -13.60 ms | Yes |

---

## 1. Queries That Improved the Most

*Which queries got faster? 
The queries that saw the most drastic improvements were **Q5 (Facebook events)**, **Q8 (Income by car make)**, and **Q6 (Red-haired Tesla drivers)**.

By how much? Why did the index help for those specific queries?*
* For filtering queries (like Q5 and Q6), B-Tree indexes allowed the query planner to bypass scanning thousands of rows (`Seq Scan`) and jump directly to the exact memory blocks holding the required data (`Index Scan` / `Bitmap Index Scan`).
* For relational queries (like Q2, Q4, Q8), indexing the Foreign Keys (`license_id`, `ssn`) was a game changer. It allowed Postgres to switch from expensive, memory-heavy `Hash Joins` to highly efficient `Nested Loop` joins.


---

## 2. Queries That Did NOT Improve

*Which queries showed little or no change? 
**Q7 (Interview keyword search)** showed absolutely no improvement, remaining a full `Seq Scan`.

Explain why — think about table size, the use of `LIKE '%...'` wildcards, or cases where a full scan is actually faster.*

* The query uses the `ILIKE '%gym%' OR ILIKE '%murder%'` syntax. Standard B-Tree indexes sort data from left to right (like a dictionary). Because the wildcard `%` is at the very beginning of the string, the index cannot be utilized. The query planner is forced to read every single row in the table to find matches.
* Additionally, the Postgres query planner will deliberately ignore indexes on very small tables (like the gym members table) because loading the entire small table into memory via a sequential scan is actually cheaper and faster than traversing an index tree.

---

## 3. Tradeoffs of Indexing

*Discuss:*
- How indexes speed up SELECT/WHERE/JOIN operations:

Indexes are powerful, but they are not free. The main tradeoffs are:
* **Faster Reads:** Indexes massively speed up `SELECT`, `WHERE`, and `JOIN` operations by providing direct pointers to data.


- How indexes slow down INSERT, UPDATE, DELETE:

* **Slower Writes:** Every time a record is `INSERTED`, `UPDATED`, or `DELETED`, the database must update the base table **and** rewrite all associated indexes. Over-indexing degrades write performance significantly.


- Storage overhead (each index takes extra disk space):

* **Storage Overhead:** Indexes are physical data structures. Each index consumes additional disk space and RAM.

- Why you wouldn't index every column:

If every column is indexed, the database will grind to a halt on write operations, and storage costs will skyrocket, mostly for indexes that the query planner rarely uses.
---

## 4. Production Recommendation

*If this were a real police database handling thousands of queries per day, which indexes would you keep? 

1. `idx_person_license`, `idx_person_ssn`, `idx_income_ssn`: Foreign keys should always be indexed to ensure fast JOIN operations, which are the backbone of relational databases.
2. `idx_facebook_date`: The Facebook check-in table is the largest in this dataset (20,000 rows). Filtering by date is a standard analytic query, and the massive read-speed benefit (dropped from 18ms to 3ms) easily justifies the storage cost.

Which would you drop? Justify your choices with evidence from your measurements.*

1. `idx_crime_city_type`: The target table is very small (~1,200 rows). A Seq Scan is fast enough, making this index unnecessary overhead.
2. `idx_dl_hair_car`: This is a highly specific composite index tailored for a single ad-hoc query (finding a specific car make and hair color). Maintaining this index permanently for an edge-case search is a bad engineering practice.

---

*© 2026 LevelUp Economy. All rights reserved.*
