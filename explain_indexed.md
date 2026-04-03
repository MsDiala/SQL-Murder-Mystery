# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.151 ms *(baseline: 0.302 ms | change: 0.151)*
**Scan Type:** Index scan 
**Index Used:** idx_crime_city_type on crime_scene_report 

```
-- Paste EXPLAIN QUERY PLAN output here
 Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.097..0.098 rows=3 loops=1)      
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=0.082..0.085 rows=3 loops=1)
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 0.343 ms
 Execution Time: 0.151 ms
(7 rows)
```

---

## Q2 — People with their driver's license details

**Execution Time:**22.251 ms *(baseline: 16.550  ms | change: -5.701)*
**Scan Type:** Seq no index used
**Index Used:** not used by optimizer 

```
-- Paste EXPLAIN QUERY PLAN output here
 Sort  (cost=1002.51..1021.29 rows=7511 width=60) (actual time=20.751..21.837 rows=7511 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 997kB
   ->  Hash Join  (cost=328.16..519.00 rows=7511 width=60) (actual time=4.062..6.881 rows=7511 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=36) (actual time=0.008..0.587 rows=7511 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=3.969..3.972 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.006..1.603 rows=10007 loops=1)
 Planning Time: 0.374 ms
 Execution Time: 22.251 ms
(11 rows)
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.058 ms *(baseline: 0.117 ms | change:0.064 )*
**Scan Type:** seq scan not used index 
**Index Used:** et_fit_now_check_in ci (not used by optimizer)

```
-- Paste EXPLAIN QUERY PLAN output here
 Sort  (cost=0.02..0.03 rows=1 width=72) (actual time=0.016..0.017 rows=0 loops=1)        
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.00..0.01 rows=1 width=72) (actual time=0.008..0.008 rows=0 loops=1)
         Join Filter: (m.id = ci.membership_id)
         ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=96) (actual time=0.008..0.008 rows=0 loops=1)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..0.00 rows=1 width=40) (never executed)
               Filter: (check_in_date = 20180109)
 Planning Time: 1.571 ms
 Execution Time: 0.058 ms
(10 rows)
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 0.085 ms *(baseline: 0.089 ms | change: 0.004)*
**Scan Type:** Index scan + seq scan 
**Index Used:** person_pkey on person p + income_pkey on income i +Seq Scan on get_fit_now_member m
```
-- Paste EXPLAIN QUERY PLAN output here
Sort  (cost=8.64..8.65 rows=1 width=68) (actual time=0.018..0.019 rows=0 loops=1)        
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.56..8.63 rows=1 width=68) (actual time=0.004..0.005 rows=0 loops=1)
         ->  Nested Loop  (cost=0.28..8.30 rows=1 width=68) (actual time=0.004..0.004 rows=0 loops=1)
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=68) (actual time=0.004..0.004 rows=0 loops=1)
                     Filter: (membership_status = 'gold'::text)
               ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=8) (never executed)
                     Index Cond: (id = m.person_id)
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.33 rows=1 width=8) (never executed)
               Index Cond: (ssn = p.ssn)
 Planning Time: 1.368 ms
 Execution Time: 0.085 ms
(13 rows)

```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 0.039 ms *(baseline: 0.081 ms | change: 0.042)*
**Scan Type:** seq scan + Index scan 
**Index Used:** Index Scan using person_pkey on person p + Seq Scan on facebook_event_checkin fe 

```
-- Paste EXPLAIN QUERY PLAN output here
Sort  (cost=8.31..8.32 rows=1 width=50) (actual time=0.010..0.011 rows=0 loops=1)        
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.003..0.004 rows=0 loops=1)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..0.00 rows=1 width=40) (actual time=0.003..0.003 rows=0 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
         ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
               Index Cond: (id = fe.person_id)
 Planning Time: 0.566 ms
 Execution Time: 0.039 ms
(10 rows)

```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.739 ms *(baseline 2.873 ms | change: 2.134)*
**Scan Type:**  Bitmap Heap Scan + index scan 
**Index Used:** Index Scan using idx_person_license_id on person p + Bitmap Index Scan on idx_license_hair_car + Bitmap Heap Scan on drivers_license dl
```
-- Paste EXPLAIN QUERY PLAN output here
 Sort  (cost=28.13..28.13 rows=2 width=40) (actual time=0.689..0.691 rows=3 loops=1)      
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=0.358..0.644 rows=3 loops=1)
         ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=0.253..0.276 rows=4 loops=1)
               Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))  
               Heap Blocks: exact=4
               ->  Bitmap Index Scan on idx_license_hair_car  (cost=0.00..4.30 rows=2 width=0) (actual time=0.228..0.228 rows=4 loops=1)
                     Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
         ->  Index Scan using idx_person_license_id on person p  (cost=0.28..8.30 rows=1 width=18) (actual time=0.088..0.089 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 0.568 ms
 Execution Time: 0.739 ms
(13 rows)
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 0.026 ms *(baseline: 0.032 ms | change: 0.006)*
**Scan Type:** index + seq scan 
**Index Used:** Index Scan using person_pkey on person p +  Seq Scan on interview i 

```
-- Paste EXPLAIN QUERY PLAN output here
 Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.004..0.004 rows=0 loops=1) 
   ->  Seq Scan on interview i  (cost=0.00..0.00 rows=1 width=36) (actual time=0.003..0.004 rows=0 loops=1)
         Filter: ((transcript ~~ '%gym%'::text) OR (transcript ~~ '%murder%'::text))      
   ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
         Index Cond: (id = i.person_id)
 Planning Time: 0.179 ms
 Execution Time: 0.026 ms
(7 rows)

```

---

## Q8 — Average income by car make

**Execution Time:** 9.464 ms *(baseline: 9.171 ms | change: -0.293)*
**Scan Type:** seq scan not useed the Index 
**Index Used:**  Seq Scan on person p +  Seq Scan on drivers_license dl +  Seq Scan on income i

```
-- Paste EXPLAIN QUERY PLAN output here
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=9.346..9.378 rows=62 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..741.79 rows=7511 width=11) (actual time=4.371..8.081 rows=5647 loops=1)
               Hash Cond: (p.ssn = i.ssn)
               ->  Hash Join  (cost=328.16..519.00 rows=7511 width=11) (actual time=2.698..5.002 rows=7511 loops=1)
                     Hash Cond: (p.license_id = dl.id)
                     ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=8) (actual time=0.004..0.526 rows=7511 loops=1)
                     ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=2.676..2.676 rows=10007 loops=1)
                           Buckets: 16384  Batches: 1  Memory Usage: 567kB
                           ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.004..1.250 rows=10007 loops=1)
               ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=1.665..1.665 rows=7514 loops=1)
                     Buckets: 8192  Batches: 1  Memory Usage: 358kB
                     ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.006..0.708 rows=7514 loops=1)
 Planning Time: 0.402 ms
 Execution Time: 9.464 ms
(19 rows)
```
