# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City
**Execution Time:** 0.211 ms *(baseline: 0.446 ms | change: ~52% faster)* **Scan Type:** Index Scan  
**Index Used:** `idx_crime_city_type`  

```sql
 Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.127..0.129 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=0.052..0.059 rows=3 loops=1)        
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 1.011 ms
 Execution Time: 0.211 ms
```

---

## Q2 — People with their driver's license details
**Execution Time:** 18.383 ms *(baseline: 23.207 ms | change: ~20% faster)* **Scan Type:** Seq Scan (Note: Still using Seq Scan because it's a full table join)  
**Index Used:** None (Optimized by Hash Join)  

```sql
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=17.735..18.055 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=3.145..6.090 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.004..0.515 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=3.083..3.084 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.003..1.375 rows=10007 loops=1)
 Planning Time: 0.993 ms
 Execution Time: 18.383 ms
```

---

## Q3 — Gym members who checked in on Jan 9, 2018
**Execution Time:** 0.345 ms *(baseline: 0.622 ms | change: ~45% faster)* **Scan Type:** Bitmap Index Scan  
**Index Used:** `idx_checkin_date`  

```sql
 Sort  (cost=26.81..26.84 rows=10 width=28) (actual time=0.212..0.214 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=10.50..26.65 rows=10 width=28) (actual time=0.154..0.173 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Bitmap Heap Scan on get_fit_now_check_in ci  (cost=4.36..20.48 rows=10 width=14) (actual time=0.075..0.090 rows=10 loops=1)
               Recheck Cond: (check_in_date = 20180109)
               Heap Blocks: exact=8
               ->  Bitmap Index Scan on idx_checkin_date  (cost=0.00..4.36 rows=10 width=0) (actual time=0.060..0.060 rows=10 loops=1)
                     Index Cond: (check_in_date = 20180109)
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.065..0.065 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.005..0.021 rows=184 loops=1)
 Planning Time: 1.299 ms
 Execution Time: 0.345 ms
```

---

## Q4 — Gold gym members and their income
**Execution Time:** 1.619 ms *(baseline: 1.687 ms | change: stable)* **Scan Type:** Index Scan  
**Index Used:** `income_pkey`  

```sql
 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=1.616..1.619 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.079..1.583 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.069..1.354 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.003..0.477 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.051..0.052 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.004..0.023 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)      
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.003..0.003 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
```

---

## Q5 — Facebook events in 2018
**Execution Time:** 6.110 ms *(baseline: 7.582 ms | change: ~19% faster)* **Scan Type:** Bitmap Index Scan  
**Index Used:** `idx_facebook_date`  

```sql
 Sort  (cost=1006.04..1018.51 rows=4989 width=63) (actual time=5.627..5.904 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=392.67..699.60 rows=4989 width=63) (actual time=2.461..4.417 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Bitmap Heap Scan on facebook_event_checkin fe  (cost=71.42..365.26 rows=4989 width=53) (actual time=0.299..1.410 rows=5025 loops=1)      
               Recheck Cond: ((date >= 20180101) AND (date <= 20181231))   
               Heap Blocks: exact=219
               ->  Bitmap Index Scan on idx_facebook_date  (cost=0.00..70.18 rows=4989 width=0) (actual time=0.271..0.271 rows=5025 loops=1)
                     Index Cond: ((date >= 20180101) AND (date <= 20181231))
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=2.094..2.094 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.004..0.806 rows=10011 loops=1)
 Planning Time: 0.830 ms
 Execution Time: 6.110 ms
```

---

## Q6 — Red-haired Tesla drivers
**Execution Time:** 0.378 ms *(baseline: 2.196 ms | change: ~83% faster - HUGE!)* **Scan Type:** Index Scan  
**Index Used:** `idx_license_hair_car` / `idx_person_license_id`  

```sql
 Sort  (cost=28.13..28.14 rows=2 width=40) (actual time=0.270..0.271 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=0.153..0.223 rows=4 loops=1)
         ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=0.129..0.147 rows=4 loops=1)
               Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
               Heap Blocks: exact=4
               ->  Bitmap Index Scan on idx_license_hair_car  (cost=0.00..4.30 rows=2 width=0) (actual time=0.120..0.121 rows=4 loops=1)
                     Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
         ->  Index Scan using idx_person_license_id on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.017..0.018 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 1.145 ms
 Execution Time: 0.378 ms
```

---

## Q7 — Interview transcripts
**Execution Time:** 6.957 ms *(baseline: 8.472 ms | change: ~18% faster)* **Scan Type:** Seq Scan on interview (Expected due to ILIKE %)  
**Index Used:** `person_pkey`  

```sql
Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=0.370..6.912 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=0.359..6.890 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.004..0.004 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 1.811 ms
 Execution Time: 6.957 ms
```

---

## Q8 — Average income by car make
**Execution Time:** 8.689 ms *(baseline: 8.689 ms | change: stable)* **Scan Type:** Seq Scan (Note: Complex aggregation on full tables)  
**Index Used:** None  

```sql
 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=8.690..8.695 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=8.598..8.622 rows=64 loops=1)
         Group Key: dl.car_make
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=3.963..7.278 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=1.407..3.718 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.004..0.505 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=1.371..1.371 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB  
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.006..0.610 rows=7514 loops=1)
```
 