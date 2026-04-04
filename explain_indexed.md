# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Before:** 0.155 ms  
**After:** 0.240 ms  
**Scan Type:** Index Scan on crime_scene_report  
**Join Method:** None  
**Notes:** After adding `idx_crime_city_type`, PostgreSQL changed the access path from a `Seq Scan` to an `Index Scan` on `crime_scene_report`. The filter is now applied through the index condition. Although execution time was slightly higher in this run, the scan type improved and the query now uses the new index instead of scanning the full table.
_

```
---------------------------------
 Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.142..0.144 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual t
ime=0.081..0.099 rows=3 loops=1)
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 0.695 ms
 Execution Time: 0.240 ms

```

---

## Q2 — People with their driver's license details

**Execution Time:** 11.663 ms *(baseline: 13.467 ms | change: -1.804 ms)*  
**Scan Type:** Seq Scan on person and drivers_license  
**Index Used:** None

```
 Sort  (cost=1002.51..1021.29 rows=7511 width=60) (actual time=11.134..11.395 rows=7511 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 997kB
   ->  Hash Join  (cost=328.16..519.00 rows=7511 width=60) (actual time=3.115..4.645 rows=7511 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=36) (actual time=0.003..0.318 rows=7511
loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=3.032..3.033 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.005.
.1.142 rows=10007 loops=1)
 Planning Time: 0.755 ms
 Execution Time: 11.663 ms

```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.026 ms *(baseline: 0.031 ms | change: -0.005 ms)*  
**Scan Type:** Seq Scan on get_fit_now_member  
**Index Used:** None

```
Sort  (cost=0.02..0.03 rows=1 width=72) (actual time=0.009..0.010 rows=0 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.00..0.01 rows=1 width=72) (actual time=0.005..0.005 rows=0 loops=1)
         Join Filter: (m.id = ci.membership_id)
         ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=96) (actual time=0.005..0.005 row
s=0 loops=1)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..0.00 rows=1 width=40) (never executed)
               Filter: (check_in_date = 20180109)
 Planning Time: 12.281 ms
 Execution Time: 0.026 ms

```

---

## Q4 — Gold gym members and their income

**Execution Time:** 0.028 ms *(baseline: 0.028 ms | change: 0 ms)*  
**Scan Type:** Seq Scan on get_fit_now_member + Index Scan on person and income  
**Index Used:** person_pkey, income_pkey

```
Sort  (cost=8.64..8.65 rows=1 width=68) (actual time=0.008..0.008 rows=0 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.56..8.63 rows=1 width=68) (actual time=0.004..0.004 rows=0 loops=1)
         ->  Nested Loop  (cost=0.28..8.30 rows=1 width=68) (actual time=0.003..0.004 rows=0 loops=1)
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=68) (actual time=0.003..0.0
03 rows=0 loops=1)
                     Filter: (membership_status = 'gold'::text)
               ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=8) (never executed)
                     Index Cond: (id = m.person_id)
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.33 rows=1 width=8) (never executed)
               Index Cond: (ssn = p.ssn)
 Planning Time: 10.454 ms
 Execution Time: 0.028 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 0.031 ms *(baseline: 0.021 ms | change: +0.010 ms)*  
**Scan Type:** Seq Scan on facebook_event_checkin  
**Index Used:** person_pkey

```
 Sort  (cost=8.31..8.32 rows=1 width=50) (actual time=0.011..0.011 rows=0 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.005..0.005 rows=0 loops=1)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..0.00 rows=1 width=40) (actual time=0.005..0.00
5 rows=0 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
         ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
               Index Cond: (id = fe.person_id)
 Planning Time: 3.242 ms
 Execution Time: 0.031 ms

```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 5.765 ms *(baseline: 1.857 ms | change: +3.908 ms)*  
**Scan Type:** Bitmap Heap Scan on drivers_license + Index Scan on person  
**Index Used:** idx_license_hair_car, idx_person_license_id

```
Sort  (cost=28.13..28.13 rows=2 width=40) (actual time=5.696..5.697 rows=3 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=3.550..5.684 rows=3 loops=1)
         ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=2.722..2.
731 rows=4 loops=1)
               Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
               Heap Blocks: exact=4
               ->  Bitmap Index Scan on idx_license_hair_car  (cost=0.00..4.30 rows=2 width=0) (actual time=2.
707..2.707 rows=4 loops=1)
                     Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
         ->  Index Scan using idx_person_license_id on person p  (cost=0.28..8.30 rows=1 width=18) (actual tim
e=0.734..0.735 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 8.104 ms
 Execution Time: 5.765 ms

```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 0.017 ms *(baseline: 0.031 ms | change: -0.014 ms)*  
**Scan Type:** Seq Scan on interview  
**Index Used:** person_pkey

```
 Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.003..0.004 rows=0 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..0.00 rows=1 width=36) (actual time=0.003..0.003 rows=0 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
   ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
         Index Cond: (id = i.person_id)
 Planning Time: 10.576 ms
 Execution Time: 0.017 ms

```

---

## Q8 — Average income by car make

**Execution Time:** 6.117 ms *(baseline: ~5.134 ms | change: +0.983 ms)*  
**Scan Type:** Seq Scan on person, drivers_license, income  
**Index Used:** None

```
 Sort  (cost=838.61..838.77 rows=65 width=55) (actual time=6.112..6.117 rows=62 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=6.070..6.088 rows=62 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..741.79 rows=7511 width=11) (actual time=3.117..5.394 rows=5647 loops=1)
               Hash Cond: (p.ssn = i.ssn)
               ->  Hash Join  (cost=328.16..519.00 rows=7511 width=11) (actual time=2.042..3.400 rows=7511 loo
ps=1)
                     Hash Cond: (p.license_id = dl.id)
                     ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=8) (actual time=0.003..0.315
 rows=7511 loops=1)
                     ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=1.819..1.820 rows=10007
loops=1)
                           Buckets: 16384  Batches: 1  Memory Usage: 567kB
                           ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual
 time=0.004..0.827 rows=10007 loops=1)
               ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=1.062..1.063 rows=7514 loops=1)

```
