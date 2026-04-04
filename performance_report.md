# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Afnan Tayem
**Date:** 31/3/2026
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.220 | 0.311 | ~0% (Small) | Yes (`idx_crime_city_type`) |
| Q2 — People + license details | 21.917 | 32.186 | None | No (Planner chose Seq Scan) |
| Q3 — Gym check-ins Jan 9 | 1.204 | 31.059 | Negative* | Yes (Bitmap Index Scan) |
| Q4 — Gold members + income | 5.908 | 4.430 | 25% | Yes (`idx_income_ssn`) |
| Q5 — Facebook events 2018 | 72.279 | 18.233 | 75% | Yes (`idx_facebook_date`) |
| Q6 — Red-haired Tesla drivers | 56.263 | 46.262 | 18% | Yes (`idx_license_hair_car`) |
| Q7 — Interview keyword search | 70.200 | 15.174 | 78% | Partial (For Join only) |
| Q8 — Income by car make | 146.448 | 30.595 | 79% | Yes (Internal Hash Joins) |

---

## 1. Queries That Improved the Most

*Which queries got faster? By how much? Why did the index help for those specific queries?*

* **Q8 (Average Income):** Improvement by **79%**. The index helped speed up the joining process between the `person`, `income`, and `drivers_license` tables. Instead of scanning all three tables, the engine was able to match records across the indexes before calculating the average.

* **Q5 (Facebook Events):** Improvement by **75%**. The engine previously had to manually scan approximately 20,000 historical records, but thanks to `idx_facebook_date`, accessing the 2018 range became direct and accurate.

* **Q7 (Transcripts):** Although text search remained slow, the overall time was significantly reduced because retrieving the names of people associated with interviews now relied on the index instead of a full scan.
---

## 2. Queries That Did NOT Improve

*Which queries showed little or no change? Explain why — think about table size, the use of `LIKE '%...'` wildcards, or cases where a full scan is actually faster.*

* **Q2 (People + License):** No improvement was observed. This is because the query requests to retrieve **all records** (10,000 rows) and sort them by name. In this case, the Query Planner determines that a sequential scan is thousands of times faster than jumping between the index and the table.
* **Q7 (Text Search Part):** The search for words (`%gym%`) was unaffected by standard indexes. B-tree indexes do not support searches beginning with a percent sign (wildcard) because they cannot determine the beginning of a word in the index.
---

## 3. Tradeoffs of Indexing

*Discuss:*
- How indexes speed up SELECT/WHERE/JOIN operations
* **Speed:** Indexes significantly speed up SELECT, JOIN, and WHERE operations because they provide a "roadmap" for the data instead of random searching.
- How indexes slow down INSERT, UPDATE, DELETE
* **Writes:** Each additional index slows down INSERT, UPDATE, and DELETE operations because the database is forced to update the index every time the original data changes.
- Storage overhead (each index takes extra disk space)
* **Storage:** Indexes consume additional hard drive space. In large systems, indexes can consume as much or as much space as the actual data.
- Why you wouldn't index every column
* **Why not index everything?** Because doing so would make data entry operations very slow and result in a huge waste of storage space with no real benefit, as the engine wouldn't use indexes for small tables or general queries.


---

## 4. Production Recommendation

*If this were a real police database handling thousands of queries per day, which indexes would you keep? Which would you drop? Justify your choices with evidence from your measurements.*

1. **Keep:**
* `idx_person_ssn` and `idx_income_ssn`: Because income verification is the most resource-intensive (as seen in Q8).
* `idx_facebook_date` and `idx_checkin_date`: Because attendance and event data grows rapidly over time, historical searches without indexes will lead to performance degradation in the future.

2. **Drop:**
* `idx_person_name`: Did not offer significant improvement in Q2, and its storage space can be saved.

3. **Upgrade:**
* For interviews (Q7), I recommend using **Full-Text Search (GIN Indexes)** instead of the standard B-tree to enable faster keyword searching within long texts.
---

*© 2026 LevelUp Economy. All rights reserved.*