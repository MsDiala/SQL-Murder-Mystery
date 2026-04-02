# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.119 ms *(baseline: 0.503 ms | change: faster by 0.384 improved)*
**Scan Type:** Index Scan
**Index Used:** idx_crime_city_type on crime_scene_report

```
--    QUERY PLAN                                                                

-----------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.058..0.072 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=0.036..0.041 rows=3 loops=1)
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 1.023 ms
 Execution Time: 0.119 ms
(7 rows)
```

---

## Q2 — People with their driver's license details

**Execution Time:** 24.366 ms *(baseline: 33.982 ms | change: Faster by 9.616 ms , improved)*
**Scan Type:** Seq Scan (person, drivers_license)
**Index Used:** None

```
-- QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------   
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=22.404..23.884 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=3.362..6.150 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.005..0.544 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=3.276..3.279 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.004..1.358 rows=10007 loops=1)    
 Planning Time: 1.331 ms
 Execution Time: 24.366 ms
(11 rows)
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.382 ms *(baseline: 0.682 ms | change: faster by 0.3 ms improved)*
**Scan Type:** Bitmap Heap Scan + Bitmap Index Scan
**Index Used:** Bitmap Index Scan on idx_checkin_date

```
--  QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------   
 Sort  (cost=26.81..26.84 rows=10 width=28) (actual time=0.282..0.284 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=10.50..26.65 rows=10 width=28) (actual time=0.240..0.260 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Bitmap Heap Scan on get_fit_now_check_in ci  (cost=4.36..20.48 rows=10 width=14) (actual time=0.114..0.132 rows=10 loops=1)    
               Recheck Cond: (check_in_date = 20180109)
               Heap Blocks: exact=8
               ->  Bitmap Index Scan on idx_checkin_date  (cost=0.00..4.36 rows=10 width=0) (actual time=0.086..0.086 rows=10 loops=1)      
                     Index Cond: (check_in_date = 20180109)
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.117..0.117 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.018..0.073 rows=184 loops=1)        
 Planning Time: 1.603 ms
 Execution Time: 0.382 ms
(15 rows)
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 3.464 ms *(baseline: 3.575 ms | change: faster by 0.111 ms no significant change)*
**Scan Type:** Seq Scan (person, get_fit_now_member), Index Scan (income) 
**Index Used:** Index Scan using income_pkey

```
--  QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=3.397..3.400 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.145..3.356 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.082..1.709 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.005..0.696 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.048..0.049 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.010..0.034 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.024..0.024 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 0.965 ms
 Execution Time: 3.464 ms
(16 rows)
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 6.801 ms *(baseline: 14.931 ms | change: faster by 8.13 major improvement)*
**Scan Type:** Bitmap Heap Scan + Bitmap Index Scan
**Index Used:** Bitmap Index Scan on idx_facebook_date

```
--   QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=1006.04..1018.51 rows=4989 width=63) (actual time=5.932..6.480 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=392.67..699.60 rows=4989 width=63) (actual time=2.952..4.734 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Bitmap Heap Scan on facebook_event_checkin fe  (cost=71.42..365.26 rows=4989 width=53) (actual time=0.287..1.218 rows=5025 loops=1)
               Recheck Cond: ((date >= 20180101) AND (date <= 20181231))
               Heap Blocks: exact=219
               ->  Bitmap Index Scan on idx_facebook_date  (cost=0.00..70.18 rows=4989 width=0) (actual time=0.262..0.263 rows=5025 loops=1)
                     Index Cond: ((date >= 20180101) AND (date <= 20181231))
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=2.552..2.554 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.008..0.976 rows=10011 loops=1)
 Planning Time: 0.920 ms
 Execution Time: 6.801 ms
(15 rows)
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.194 ms *(baseline: 3.860 ms | change: Faster by 3.666 ms major improvement)*
**Scan Type:** Bitmap Heap Scan + Bitmap Index Scan (drivers_license), Index Scan (person) 
**Index Used:** idx_license_hair_car, idx_person_license_id

```
--   QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=28.13..28.14 rows=2 width=40) (actual time=0.156..0.158 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=0.070..0.113 rows=4 loops=1)
         ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=0.054..0.060 rows=4 loops=1)
               Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
               Heap Blocks: exact=4
               ->  Bitmap Index Scan on idx_license_hair_car  (cost=0.00..4.30 rows=2 width=0) (actual time=0.049..0.049 rows=4 loops=1)
                     Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
         ->  Index Scan using idx_person_license_id on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.012..0.012 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 0.386 ms
 Execution Time: 0.194 ms
(13 rows)
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 7.581 ms *(baseline: 17.692 ms | change: faster by 10.111 ms , major improvement)*
**Scan Type:** Seq Scan (interview), Index Scan (person) 
**Index Used:** None
**Note:** Performance improved due to caching and memory effects, not due to index usage. The query still performs a full table scan because wildcard searches prevent index usage.

```
-- QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=0.528..7.487 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=0.508..7.428 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.010..0.010 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 1.016 ms
 Execution Time: 7.581 ms
(8 rows)
```

---

## Q8 — Average income by car make

**Execution Time:** 22.786 ms *(baseline: 21.454 ms | change: slower by 1.332 no improvement)*
**Scan Type:** Seq Scan (person, income, drivers_license)
**Index Used:** none

```
-- QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=22.549..22.554 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=22.441..22.462 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=5.483..20.113 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=2.694..13.398 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.007..3.851 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=2.647..2.648 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.006..1.260 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=2.735..2.736 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.005..1.299 rows=10007 loops=1)
 Planning Time: 0.960 ms
 Execution Time: 22.786 ms
(19 rows)
```
