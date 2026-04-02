# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.288 ms *(baseline: 0.835 ms | change: faster)*  
**Scan Type:** Index Scan  
**Index Used:** idx_crime_city_type
```
-- Paste EXPLAIN QUERY PLAN output here
```
 Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.208..0.208 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=0.133..0.146 rows=3 loops=1)
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 2.591 ms
 Execution Time: 0.288 ms
(7 rows)
---

## Q2 — People with their driver's license details

**Execution Time:** 53.228 ms *(baseline: 93.306 ms | change: faster)*  
**Scan Type:** Seq Scan  
**Index Used:** None

```
-- Paste EXPLAIN QUERY PLAN output here
```
Q2 — People with their driver’s license details
Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=50.425..52.075 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=5.678..13.117 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.007..1.251 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=5.655..5.658 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.006..2.377 rows=10007 loops=1)
 Planning Time: 0.359 ms
 Execution Time: 53.228 ms
(11 rows)

---

## Q3 — Gym members who checked in on January 9, 2018


**Execution Time:** 0.517 ms *(baseline: 1.002 ms | change: faster)*  
**Scan Type:** Bitmap Index Scan + Bitmap Heap Scan  
**Index Used:** idx_checkin_date

```
-- Paste EXPLAIN QUERY PLAN output here
```


Sort  (cost=26.81..26.84 rows=10 width=28) (actual time=0.361..0.388 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=10.50..26.65 rows=10 width=28) (actual time=0.319..0.378 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Bitmap Heap Scan on get_fit_now_check_in ci  (cost=4.36..20.48 rows=10 width=14) (actual time=0.214..0.243 rows=10 loops=1)
               Recheck Cond: (check_in_date = 20180109)
               Heap Blocks: exact=8
               ->  Bitmap Index Scan on idx_checkin_date  (cost=0.00..4.36 rows=10 width=0) (actual time=0.184..0.184 rows=10 loops=1)
                     Index Cond: (check_in_date = 20180109)
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.088..0.114 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.010..0.059 rows=184 loops=1)
 Planning Time: 4.167 ms
 Execution Time: 0.517 ms
(15 rows)


---

## Q4 — Gold gym members and their income


**Execution Time:** 3.686 ms *(baseline: 4.398 ms | change: slightly faster)*  
**Scan Type:** Seq Scan + Index Scan  
**Index Used:** income_pkey

```
-- Paste EXPLAIN QUERY PLAN output here
```

 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=3.619..3.630 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.278..3.572 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.168..2.748 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.025..0.997 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.116..0.117 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.016..0.083 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.011..0.011 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 1.378 ms
 Execution Time: 3.686 ms
(16 rows)

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 11.953 ms *(baseline: 16.363 ms | change: faster)*  
**Scan Type:** Bitmap Index Scan + Bitmap Heap Scan  
**Index Used:** idx_facebook_date
```
-- Paste EXPLAIN QUERY PLAN output here
```


 Sort  (cost=1006.04..1018.51 rows=4989 width=63) (actual time=10.922..11.476 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=392.67..699.60 rows=4989 width=63) (actual time=4.531..8.321 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Bitmap Heap Scan on facebook_event_checkin fe  (cost=71.42..365.26 rows=4989 width=53) (actual time=0.596..2.172 rows=5025 loops=1)
               Recheck Cond: ((date >= 20180101) AND (date <= 20181231))
               Heap Blocks: exact=219
               ->  Bitmap Index Scan on idx_facebook_date  (cost=0.00..70.18 rows=4989 width=0) (actual time=0.559..0.560 rows=5025 loops=1)
                     Index Cond: ((date >= 20180101) AND (date <= 20181231))
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=3.908..3.909 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.013..1.710 rows=10011 loops=1)
 Planning Time: 1.237 ms
 Execution Time: 11.953 ms
(15 rows)

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.371 ms *(baseline: 6.604 ms | change: much faster)*  
**Scan Type:** Bitmap Index Scan + Index Scan  
**Index Used:** idx_license_hair_car, idx_person_license_id
```
-- Paste EXPLAIN QUERY PLAN output here
```


 Sort  (cost=28.13..28.14 rows=2 width=40) (actual time=0.317..0.319 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=0.201..0.304 rows=4 loops=1)
         ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=0.159..0.172 rows=4 loops=1)
               Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
               Heap Blocks: exact=4
               ->  Bitmap Index Scan on idx_license_hair_car  (cost=0.00..4.30 rows=2 width=0) (actual time=0.152..0.152 rows=4 loops=1)
                     Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
         ->  Index Scan using idx_person_license_id on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.028..0.029 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 0.596 ms
 Execution Time: 0.371 ms
(13 rows)
---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 22.105 ms *(baseline: 19.354 ms | change: no improvement)*  
**Scan Type:** Seq Scan  
**Index Used:** None

```
-- Paste EXPLAIN QUERY PLAN output here
```

 Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=0.918..22.079 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=0.907..21.816 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.061..0.061 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 3.326 ms
 Execution Time: 22.105 ms
(8 rows)
---

## Q8 — Average income by car make


**Execution Time:** 23.415 ms *(baseline: 63.585 ms | change: much faster)*  
**Scan Type:** Seq Scan + Hash Join  
**Index Used:** None (indirect improvement)

```
-- Paste EXPLAIN QUERY PLAN output here
```

 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=23.013..23.036 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=22.778..22.870 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=7.369..17.223 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=2.822..9.648 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.015..1.110 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=2.763..2.768 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.028..1.054 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=4.341..4.342 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.009..1.874 rows=10007 loops=1)
 Planning Time: 1.560 ms
 Execution Time: 23.415 ms
(19 rows)


