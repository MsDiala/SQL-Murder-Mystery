# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

**Date:** April 4, 2026

## Q1 — All murders in SQL City
**Execution Time:** 1.83 ms (baseline: 0.73 ms)  
**Scan Type:** Index Scan  
**Index Used:** idx_crime_city_type





## Q2 — People with their driver's license details
**Execution Time:** 38.11 ms (baseline: 51.20 ms)  
**Scan Type:** Seq Scan (still)  
**Index Used:** Partially (person license_id)





## Q3 — Gym members who checked in on January 9, 2018
**Execution Time:** 2.09 ms (baseline: 0.70 ms)  
**Scan Type:** Bitmap Index Scan  
**Index Used:** idx_checkin_date


## Q4 — Gold gym members and their income
**Execution Time:** 8.42 ms (baseline: 4.85 ms)  
**Scan Type:** Seq Scan on person  
**Index Used:** Partially




## Q5 — People who attended Facebook events in 2018
**Execution Time:** 26.16 ms (baseline: 18.20 ms)  
**Scan Type:** Bitmap Index Scan  
**Index Used:** idx_facebook_date



## Q6 — Red-haired Tesla drivers
**Execution Time:** 2.83 ms (baseline: 5.26 ms)  
**Scan Type:** Bitmap Index Scan + Index Scan  
**Index Used:** idx_drivers_hair_car + idx_person_license **(Best improvement)**







## Q7 — Interview transcripts mentioning the gym or murder
**Execution Time:** 17.09 ms (baseline: 29.70 ms)  
**Scan Type:** Seq Scan (still)  
**Index Used:** No direct index on ILIKE






## Q8 — Average income by car make
**Execution Time:** 19.62 ms (baseline: 20.14 ms)  
**Scan Type:** Seq Scan on person  
**Index Used:** Partially


**Summary:** Notable improvements seen in Q6 (+46%) and Q7 (+42%). Some small-table queries became slightly slower due to index overhead.