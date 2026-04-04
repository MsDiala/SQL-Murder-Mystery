# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Ibrahim Yasin 
**Date:** 4/4/2026
**Database:** `murder_mystery` (PostgreSQL)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.155 | 0.240 | -0.085 | Yes |
| Q2 — People + license details | 13.467 | 11.663 | +1.804 | No |
| Q3 — Gym check-ins Jan 9 | 0.031 | 0.026 | +0.005 | No |
| Q4 — Gold members + income | 0.028 | 0.028 | 0 | Partial |
| Q5 — Facebook events 2018 | 0.021 | 0.031 | -0.010 | No |
| Q6 — Red-haired Tesla drivers | 1.857 | 5.765 | -3.908 | Yes |
| Q7 — Interview keyword search | 0.031 | 0.017 | +0.014 | No |
| Q8 — Income by car make | 5.134 | 6.117 | -0.983 | No |

---

## 1. Queries That Improved the Most

The queries that showed improvement were Q2, Q3, and Q7.

- **Q2** improved by about 1.8 ms. Even though the execution plan still used sequential scans, the overall execution time decreased slightly.
- **Q3** improved slightly because the query returned no rows, so the work required was minimal.
- **Q7** also showed a small improvement in execution time, although the scan type remained unchanged.

The most important structural improvement was in **Q6**, where PostgreSQL switched from sequential scans to a Bitmap Index Scan and Index Scan. Even though execution time increased, this change is important because it shows that the index is being used and will scale better with larger datasets.

---

## 2. Queries That Did NOT Improve

Several queries did not improve or became slightly slower:

- **Q1**: Execution time increased slightly, even though the scan changed from Seq Scan to Index Scan. This is likely because the table is small, so a full scan was already efficient.
- **Q4**: No change in execution time because the query returned no rows.
- **Q5**: PostgreSQL still used a sequential scan. The planner likely decided that using the index was not worth it.
- **Q8**: Execution time increased because the query involves joins and aggregation over many rows, so sequential scans were still preferred.

For **Q7**, the use of:
```sql
ILIKE '%gym%' OR ILIKE '%murder%'

---
3. Tradeoffs of Indexing

Indexes provide faster data retrieval by allowing PostgreSQL to quickly locate matching rows instead of scanning entire tables.

However, they also come with tradeoffs:

Faster reads: Queries using WHERE, JOIN, and filtering conditions benefit significantly.
Slower writes: INSERT, UPDATE, and DELETE operations become slower because indexes must also be updated.
Storage cost: Each index consumes additional disk space.
Over-indexing problem: Adding too many indexes can degrade performance instead of improving it.

Therefore, indexes should only be created when they provide clear benefits for important queries.


4. Production Recommendation

If this were a real production system, I would keep the following indexes:

CREATE INDEX idx_crime_city_type ON crime_scene_report(city, type);
CREATE INDEX idx_person_license_id ON person(license_id);
CREATE INDEX idx_checkin_date ON get_fit_now_check_in(check_in_date);
CREATE INDEX idx_checkin_membership ON get_fit_now_check_in(membership_id);
CREATE INDEX idx_member_status ON get_fit_now_member(membership_status);
CREATE INDEX idx_member_person_id ON get_fit_now_member(person_id);
CREATE INDEX idx_facebook_date ON facebook_event_checkin(date);
CREATE INDEX idx_facebook_person_id ON facebook_event_checkin(person_id);
CREATE INDEX idx_license_hair_car ON drivers_license(hair_color, car_make);

These indexes are useful because they match the most common filters and joins in the queries.

I would reconsider or possibly remove:

CREATE INDEX idx_interview_person_id ON interview(person_id);
CREATE INDEX idx_person_ssn ON person(ssn);

because they did not show clear performance improvements in the tested queries.

Final Conclusion

This experiment shows that indexing does not always reduce execution time in small datasets, but it can significantly improve query execution plans.

The most meaningful improvement was in Q6, where the query shifted from sequential scanning to index-based access. Other queries showed minimal or no improvement because of small table sizes, query patterns, or planner decisions.

Indexes are most effective when applied to selective filters and join columns, but they must be used carefully to avoid unnecessary overhead.
