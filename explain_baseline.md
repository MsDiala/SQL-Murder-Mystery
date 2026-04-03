# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.314 ms
**Scan Type:** Seq Scan
**Join Method:** None

```sql
                                                     QUERY PLAN                                                     
--------------------------------------------------------------------------------------------------------------------
 Sort  (cost=34.43..34.44 rows=1 width=52) (actual time=0.274..0.275 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=52) (actual time=0.015..0.242 rows=3 loops=1)
         Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
         Rows Removed by Filter: 1225
 Planning Time: 0.454 ms
 Execution Time: 0.314 ms
```

---

## Q2 — People with their driver's license details

**Execution Time:** 47.013 ms
**Scan Type:** Seq Scan
**Join Method:** Hash Join

```sql
                                                               QUERY PLAN                                                                
-----------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=44.979..46.373 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=5.886..11.066 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.005..1.011 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=5.782..5.783 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.004..2.328 rows=10007 loops=1)
 Planning Time: 0.459 ms
 Execution Time: 47.013 ms
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.450 ms
**Scan Type:** Seq Scan
**Join Method:** Hash Join

```sql
                                                             QUERY PLAN                                                              
-------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=58.12..58.14 rows=10 width=28) (actual time=0.426..0.428 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=6.14..57.95 rows=10 width=28) (actual time=0.126..0.417 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..51.79 rows=10 width=14) (actual time=0.024..0.309 rows=10 loops=1)
               Filter: (check_in_date = 20180109)
               Rows Removed by Filter: 2693
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.091..0.092 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.005..0.038 rows=184 loops=1)
 Planning Time: 0.480 ms
 Execution Time: 0.450 ms
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 2.710 ms
**Scan Type:** Seq Scan, Index Scan
**Join Method:** Nested Loop, Hash Join

```sql
                                                               QUERY PLAN                                                                
-----------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=2.677..2.683 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.090..2.654 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.081..2.443 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.005..0.947 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.061..0.061 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.007..0.042 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.003..0.003 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 0.433 ms
 Execution Time: 2.710 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 11.803 ms
**Scan Type:** Seq Scan
**Join Method:** Hash Join

```sql
                                                               QUERY PLAN                                                               
----------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=1157.80..1170.27 rows=4987 width=62) (actual time=10.992..11.448 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 718kB
   ->  Hash Join  (cost=321.25..851.50 rows=4987 width=62) (actual time=4.091..8.859 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..517.16 rows=4987 width=52) (actual time=0.009..3.275 rows=5025 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
               Rows Removed by Filter: 14986
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=4.061..4.061 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.003..1.605 rows=10011 loops=1)
 Planning Time: 0.216 ms
 Execution Time: 11.803 ms
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 4.100 ms
**Scan Type:** Seq Scan
**Join Method:** Hash Join

```sql
                                                           QUERY PLAN                                                            
---------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=475.54..475.54 rows=2 width=40) (actual time=4.077..4.079 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..475.53 rows=2 width=40) (actual time=2.973..4.062 rows=4 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.006..0.916 rows=10011 loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=1.731..1.731 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.200..1.727 rows=4 loops=1)
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 0.233 ms
 Execution Time: 4.100 ms
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 15.964 ms
**Scan Type:** Seq Scan, Index Scan
**Join Method:** Nested Loop

```sql
                                                         QUERY PLAN                                                          
-----------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.29..134.17 rows=1 width=60) (actual time=0.876..15.946 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=50) (actual time=0.867..15.924 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.004..0.004 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 1.164 ms
 Execution Time: 15.964 ms
```

---

## Q8 — Average income by car make

**Execution Time:** 16.495 ms
**Scan Type:** Seq Scan
**Join Method:** Hash Join, HashAggregate

```sql
                                                                  QUERY PLAN                                                                   
-----------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=16.434..16.441 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=16.329..16.380 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=7.236..13.817 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=2.742..7.266 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.004..1.101 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=2.728..2.729 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.004..1.128 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=4.410..4.411 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.003..2.013 rows=10007 loops=1)
 Planning Time: 0.470 ms
 Execution Time: 16.495 ms
```

---
