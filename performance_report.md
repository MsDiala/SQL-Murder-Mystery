# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Rayan Bdour  
**Date:** 2026-04-02  
**Database:** PostgreSQL (Docker — murder_mystery)

---

## Summary Table

| Query                         | Baseline (ms)| Indexed (ms)| Improvement                      | Index Used? |
|-------------------------------|--------------|-------------|----------------------------------|-------------|
| Q1 — Murders in SQL City      | 0.835        | 0.288       | ~65% faster                      | Yes         |
| Q2 — People + license details | 93.306       | 53.228      | ~43% faster                      | No          |
| Q3 — Gym check-ins Jan 9      | 1.002        | 0.517       | ~48% faster                      | Yes         |
| Q4 — Gold members + income    | 4.398        | 3.686       | ~16% faster                      | Partial     |
| Q5 — Facebook events 2018     | 16.363       | 11.953      | ~27% faster                      | Yes         |
| Q6 — Red-haired Tesla drivers | 6.604        | 0.371       | ~94% faster                      | Yes         |
| Q7 — Interview keyword search | 19.354       | 22.105      | No improvement (slightly slower) | No          |
| Q8 — Income by car make       | 63.585       | 23.415      | ~63% faster                      | Indirect    |

---

## 1. Queries That Improved the Most

The queries that showed the most improvement were **Q6, Q8, and Q1**.

**Q6 (Red-haired Tesla drivers)** improved dramatically (~94% faster).  
  This is because a **composite index on (hair_color, car_make)** was used.  
  The database no longer scans all 10,000 rows — it directly jumps to the matching rows.

**Q8 (Average income by car make)** improved significantly (~63% faster).  
  Even though Seq Scan is still used, indexing join columns improved join efficiency and reduced processing time.

**Q1 (Murders in SQL City)** improved (~65% faster).  
  The index on `(city, type)` allowed PostgreSQL to use an **Index Scan instead of Seq Scan**, avoiding full table scanning.

**Q3 and Q5** also improved because filtering on indexed date columns enabled **Bitmap Index Scans**, which are much faster than full scans.

---

## 2. Queries That Did NOT Improve

**Q7 (Interview keyword search)** did not improve and became slightly slower.  
  This is because the query uses:
    ILIKE '%gym%' OR ILIKE '%murder%'
    This pattern prevents index usage because the database cannot determine where the text starts.  
    Therefore, a **Seq Scan is required**, and indexing does not help.

**Q2 (People + license details)** still uses Seq Scan.  
Even though performance improved, PostgreSQL chose a full scan because:
  The result includes almost all rows (~10,000)
  Using indexes would not significantly reduce work

---

## 3. Tradeoffs of Indexing

Indexes provide both advantages and disadvantages:

### Advantages
- Faster query execution for SELECT statements
- Efficient filtering using WHERE conditions
- Faster joins between tables
- Avoids scanning entire tables

### Disadvantages
- Slower INSERT, UPDATE, and DELETE operations (indexes must be updated)
- Increased storage usage
- Too many indexes can reduce performance due to maintenance overhead

### Important Insight
Indexes are most effective when used on:
- Large tables
- Frequently filtered columns
- Join keys

Indexes are not effective for:
- Small tables
- Columns used with wildcard searches like `%text%`

---

## 4. Production Recommendation

If this database were used in production, the following indexes should be kept:

### Keep
- `idx_crime_city_type` → improves filtering in Q1  
- `idx_checkin_date` → efficient date filtering in Q3  
- `idx_facebook_date` → improves large dataset filtering in Q5  
- `idx_license_hair_car` → highly efficient composite index (Q6)  
- `idx_person_license_id` → improves joins across multiple queries  

### Keep (optional but useful)
- `idx_person_ssn` and `idx_income_ssn` → improve join performance in Q8  

### Do NOT rely on indexes for
- Text search with `%...%` patterns (Q7)  
- Small tables where Seq Scan is already efficient  

### Final Recommendation
Use indexes strategically on:
- High-selectivity filters  
- Join columns  
- Frequently queried fields  

Avoid over-indexing to balance performance, storage, and write efficiency.

---


*© 2026 LevelUp Economy. All rights reserved.*
