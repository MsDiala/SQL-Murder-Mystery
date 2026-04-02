# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`

---



## Q1 — All murders in SQL City

**Execution Time:** 0.835 ms  
**Scan Type:** Seq Scan  
**Notes:** Full table scan on crime_scene_report; 1225 rows were scanned and filtered out to return only 3 matching rows.


```
-- Paste EXPLAIN ANALYZE output here
```
Sort (cost=34.43..34.44 rows=1 width=53) (actual time=0.732..0.734 rows=3 loops=1)
Sort Key: date DESC
Sort Method: quicksort Memory: 25kB
-> Seq Scan on crime_scene_report (cost=0.00..34.42 rows=1 width=53) (actual time=0.024..0.494 rows=3 loops=1)
Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
Rows Removed by Filter: 1225
Planning Time: 1.230 ms
Execution Time: 0.835 ms
---


---

## Q2 — People with their driver's license details

**Execution Time:** 93.306 ms  
**Scan Type:** Seq Scan (person, drivers_license)  
**Notes:** Both tables fully scanned; Hash Join used; expensive sort due to large result set (~10k rows)


```
-- Paste EXPLAIN ANALYZE output here
```
Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=89.359..92.055 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=9.498..38.119 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.019..5.942 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=9.240..9.267 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.013..3.506 rows=10007 loops=1)
 Planning Time: 12.253 ms
 Execution Time: 93.306 ms

---


---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 1.002 ms  
**Scan Type:** Seq Scan (check_in table)  
**Notes:** Full scan on get_fit_now_check_in; 2693 rows filtered out by date condition.


```
-- Paste EXPLAIN ANALYZE output here
```
 Sort  (cost=58.12..58.14 rows=10 width=28) (actual time=0.946..0.952 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=6.14..57.95 rows=10 width=28) (actual time=0.287..0.926 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..51.79 rows=10 width=14) (actual time=0.039..0.656 rows=10 loops=1)
               Filter: (check_in_date = 20180109)
               Rows Removed by Filter: 2693
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.226..0.227 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.059..0.130 
rows=184 loops=1)
 Planning Time: 1.135 ms
 Execution Time: 1.002 ms

---


---

## Q4 — Gold gym members and their income


**Execution Time:** 4.398 ms  
**Scan Type:** Seq Scan + Index Scan  
**Notes:** Seq Scan on person and member tables; Index Scan used on income (efficient lookup by SSN).



```
-- Paste EXPLAIN ANALYZE output here
```
Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=4.298..4.304 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.133..4.237 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.118..3.758 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.011..1.460 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.086..0.086 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.015..0.061 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.006..0.006 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 1.280 ms
 Execution Time: 4.398 ms
(16 rows)

---

## Q5 — People who attended Facebook events in 2018


**Execution Time:** 16.363 ms  
**Scan Type:** Seq Scan (facebook_event_checkin, person)  
**Notes:** Large table scan (20k rows); heavy filtering on date removed ~15k rows.

```
-- Paste EXPLAIN ANALYZE output here
```

 Sort  (cost=1159.80..1172.27 rows=4987 width=63) (actual time=15.280..15.894 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=321.25..853.50 rows=4987 width=63) (actual time=5.010..12.330 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..519.16 rows=4987 width=53) (actual time=0.024..4.293 rows=5025 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
               Rows Removed by Filter: 14986
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=4.946..4.947 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.009..2.103 rows=10011 loops=1)
 Planning Time: 0.481 ms
 Execution Time: 16.363 ms

---


## Q6 — Red-haired Tesla drivers


**Execution Time:** 6.604 ms  
**Scan Type:** Seq Scan (person, drivers_license)  
**Notes:** drivers_license scanned بالكامل (~10k rows) to find only 4 matches → inefficient filtering.


```
-- Paste EXPLAIN ANALYZE output here
```
 Sort  (cost=475.54..475.54 rows=2 width=40) (actual time=6.561..6.566 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..475.53 rows=2 width=40) (actual time=4.733..6.514 rows=4 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.010..1.388 rows=10011 loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=2.894..2.896 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.364..2.881 rows=4 loops=1)
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 0.299 ms
 Execution Time: 6.604 ms
(13 rows)


---

## Q7 — Interview transcripts mentioning the gym or murder


**Execution Time:** 19.354 ms  
**Scan Type:** Seq Scan (interview table)  
**Notes:** ILIKE with wildcard (%...%) prevents index usage → full scan required.



```
-- Paste EXPLAIN ANALYZE output here
```
 Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=0.846..19.322 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=0.836..19.263 rows=4 loops=1)     
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.009..0.009 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 3.154 ms
 Execution Time: 19.354 ms
(8 rows)

---

## Q8 — Average income by car make


**Execution Time:** 63.585 ms  
**Scan Type:** Seq Scan (all tables)  
**Notes:** Heavy aggregation with multiple joins; all tables scanned  → expensive operation.


```
-- Paste EXPLAIN ANALYZE output here
```
 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=62.170..62.181 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=61.161..61.246 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=24.486..49.691 rows=7514 loops=1)    
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=6.031..23.970 rows=7514 loops=1)                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.062..9.549 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=5.932..5.933 rows=7514 loops=1)                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.015..2.318 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=18.236..18.236 rows=10007 loops=1) 
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.021..4.530 rows=10007 loops=1)
 Planning Time: 5.295 ms
 Execution Time: 63.585 ms
(19 rows)
##  Optimization Targets (Seq Scan on Large Tables)

The following queries perform sequential scans on large tables and should be optimized:

- **Q2:** Seq Scan on `person` and `drivers_license` (~10k rows each)
- **Q3:** Seq Scan on `get_fit_now_check_in` (filters many rows unnecessarily)
- **Q5:** Seq Scan on `facebook_event_checkin` (~20k rows, large filtering)
- **Q6:** Seq Scan on `drivers_license` (~10k rows, only 4 results needed)
- **Q7:** Seq Scan on `interview` (~5k rows, unavoidable due to wildcard search)
- **Q8:** Seq Scan on multiple large tables (`person`, `income`, `drivers_license`)

---

### Less Critical
- **Q1:** Seq Scan but table is small (~1k rows)
- **Q4:** Mixed (Seq Scan + Index Scan), acceptable performance