# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Rahaf Manaseer  
**Date:** 02/04/2026  
**Database:** `murder_mystery` (PostgreSQL)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|---------------|--------------|-------------|-------------|
| Q1 — Murders in SQL City | 0.887 | 0.152 | 0.735 | idx_crime_city_type |
| Q2 — People + license details | 15.785 | 15.785 | 0 | idx_person_license_id |
| Q3 — Gym check-ins Jan 9 | 0.695 | 0.695 | 0 | idx_checkin_date |
| Q4 — Gold members + income | 2.826 | 2.826 | 0 | idx_member_status, income_pkey |
| Q5 — Facebook events 2018 | 13.359 | 13.359 | 0 | idx_facebook_date, idx_facebook_person_id |
| Q6 — Red-haired Tesla drivers | 0.653 | 0.653 | 0 | idx_license_hair_car, idx_person_license_id |
| Q7 — Interview keyword search | 8.562 | 8.562 | 0 | idx_interview_person_id |
| Q8 — Income by car make | 9.040 | 9.040 | 0 | idx_person_ssn, idx_person_license_id |

---

## 1. Queries That Improved the Most

- **Q1 — Murders in SQL City:** Execution time dropped from 0.887 ms → 0.152 ms.  
  **Why:** The `idx_crime_city_type` index allowed the database to skip a full scan of `crime_scene_report` and quickly locate relevant rows.  
- The rest of the queries did not improve significantly due to small table sizes or because the queries relied on LIKE searches or small joins.

---

## 2. Queries That Did NOT Improve

- **Q2, Q3, Q4, Q5, Q6, Q7, Q8:**  
  - Q2: Seq Scan did not change because the table is relatively small.  
  - Q7: Using `ILIKE '%gym%'` prevented any index usage.  
  - Q3, Q4, Q5, Q6, Q8: Tables are small or Hash Joins were already efficient enough.

---

## 3. Tradeoffs of Indexing

- **Advantages:** Speeds up SELECT queries with WHERE conditions and JOIN operations.  
- **Disadvantages:** Slows down INSERT/UPDATE/DELETE operations due to index maintenance and increases disk usage.  
- **Storage:** Each index uses additional disk space (usually less than the table size).  
- **Design Choice:** Do not create indexes on every column; focus on columns frequently used in WHERE or JOIN clauses.

---

## 4. Production Recommendation

- Keep indexes that improved performance for larger queries:  
  - `idx_crime_city_type` (Q1)  
  - `idx_checkin_date` (Q3)  
  - `idx_facebook_date` and `idx_facebook_person_id` (Q5)  
  - `idx_license_hair_car` and `idx_person_license_id` (Q6)  
- Ignore indexes that did not improve queries or are on small columns, such as Q2 and Q4.  
- This approach balances read speed, storage usage, and write performance.

---

*© 2026 LevelUp Economy. All rights reserved.*