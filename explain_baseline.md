# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.503 ms
**Scan Type:** Seq Scan
**Join Method:** None
Flag: No major issue

```
--                                                      QUERY PLAN                                  

--------------------------------------------------------------------------------------------------------------------
 Sort  (cost=34.43..34.44 rows=1 width=53) (actual time=0.426..0.441 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=53) (actual time=0.025..0.293 rows=3 loops=1)
         Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
         Rows Removed by Filter: 1225
 Planning Time: 1.034 ms
 Execution Time: 0.503 ms
(8 rows)
```

---

## Q2 — People with their driver's license details

**Execution Time:** 33.982 ms
**Scan Type:** Seq Scan on person and drivers_license
**Join Method:** Hash Join
Flag: Seq Scan on large tables — optimization target

```
--  QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------   
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=32.962..33.618 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=7.815..17.087 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.006..1.456 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=7.714..7.716 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.028..4.920 rows=10007 loops=1)    
 Planning Time: 2.214 ms
 Execution Time: 33.982 ms
(11 rows)
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.682 ms
**Scan Type:** Seq Scan (get_fit_now_check_in), Seq Scan (get_fit_now_member)
**Join Method:** Hash Join

```
--   QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------       
 Sort  (cost=58.12..58.14 rows=10 width=28) (actual time=0.617..0.629 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=6.14..57.95 rows=10 width=28) (actual time=0.133..0.604 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..51.79 rows=10 width=14) (actual time=0.053..0.507 rows=10 loops=1)
               Filter: (check_in_date = 20180109)
               Rows Removed by Filter: 2693
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.070..0.071 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.006..0.043 rows=184 loops=1)        
 Planning Time: 1.086 ms
 Execution Time: 0.682 ms
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 3.575 ms
**Scan Type:** seq scan on person and get_fit_now_member // index scan on income 
**Join Method:** Hash Join

```
--  QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------   
 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=3.404..3.409 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.139..3.369 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.077..2.364 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.007..0.976 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.052..0.052 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.011..0.036 rows=68 loops=1)    
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.014..0.014 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 1.459 ms
 Execution Time: 3.575 ms
(16 rows)
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 14.931 ms
**Scan Type:** Seq Scan on facebook_event_checkin and person
**Join Method:** Hash Join
Flag: Major — large table scan on facebook_event_checkin

```
--  QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------    
 Sort  (cost=1159.80..1172.27 rows=4987 width=63) (actual time=14.153..14.709 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=321.25..853.50 rows=4987 width=63) (actual time=3.461..12.358 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..519.16 rows=4987 width=53) (actual time=0.044..6.003 rows=5025 loops=1)     
               Filter: ((date >= 20180101) AND (date <= 20181231))
               Rows Removed by Filter: 14986
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=3.274..3.275 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.008..1.407 rows=10011 loops=1)
 Planning Time: 0.401 ms
 Execution Time: 14.931 ms
(13 rows)
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 3.860 ms
**Scan Type:** seq scan on person and drivers_license
**Join Method:** Hash Join
Flag: Large table scan with highly selective filter — strong optimization target

```
--   QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=475.54..475.54 rows=2 width=40) (actual time=3.789..3.804 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..475.53 rows=2 width=40) (actual time=3.097..3.749 rows=4 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.006..0.863 rows=10011 loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=1.847..1.848 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.161..1.837 rows=4 loops=1)
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 0.686 ms
 Execution Time: 3.860 ms
(13 rows)
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 17.692 ms
**Scan Type:** seq scan on interview and index scan on person using person primary key
**Join Method:** Nested loop 
Flag: Seq Scan due to wildcard search — not easily optimized

```
--  QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=0.792..17.622 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=0.778..16.038 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.388..0.388 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 2.083 ms
 Execution Time: 17.692 ms
(8 rows)
```

---

## Q8 — Average income by car make

**Execution Time:** 21.454 ms
**Scan Type:** seq scan on person, income and driver_license
**Join Method:** Hash Join
Flag: Multiple large table scans — optimization opportunity (limited due to aggregation)

```
--   QUERY PLAN                                                                

-----------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=21.189..21.204 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=20.997..21.018 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=9.587..19.149 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=2.264..9.445 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.007..1.204 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=2.230..2.231 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.006..1.070 rows=7514 loops=1)     
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=7.247..7.248 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.019..5.125 rows=10007 loops=1)
 Planning Time: 0.981 ms
 Execution Time: 21.454 ms
(19 rows)
```
