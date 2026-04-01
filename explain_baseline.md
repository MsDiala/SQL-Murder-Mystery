# explain_baseline.md — Before Indexing

<<<<<<< stretch-performance
> Run each query with `EXPLAIN ANALYZE` and paste the output below.
> Connect: `docker exec -it murder_db psql -U postgres -d murder_mystery`
=======
> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`
>>>>>>> master

---

## Q1 — All murders in SQL City

<<<<<<< stretch-performance
**Execution Time:** 0.453 ms
**Scan Type:** Seq Scan on crime_scene_report
**Notes:** Filter removes 1225 rows to return only 3 —  optimization target

```
Sort  (cost=34.43..34.44 rows=1 width=53) (actual time=0.425..0.427 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=53) (actual time=0.053..0.413 rows=3 loops=1)
         Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
         Rows Removed by Filter: 1225
 Planning Time: 0.125 ms
 Execution Time: 0.453 ms
=======
**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
-- Paste EXPLAIN ANALYZE output here
>>>>>>> master
```

---

## Q2 — People with their driver's license details

<<<<<<< stretch-performance
**Execution Time:** 63.802 ms
**Scan Type:** Seq Scan on person + Seq Scan on drivers_license
**Join:** Hash Join
**Notes:** Two large tables fully scanned (10011 + 10007 rows) — ⚠️ optimization target

```
Sort  (cost=1215.75..1240.78 rows=10011 width=60) (actual time=60.833..62.492 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10011 width=60) (actual time=9.625..23.261 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.015..6.177 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=9.284..9.287 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.033..3.653 rows=10007 loops=1)
 Planning Time: 1.689 ms
 Execution Time: 63.802 ms
=======
**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
-- Paste EXPLAIN ANALYZE output here
>>>>>>> master
```

---

## Q3 — Gym members who checked in on January 9, 2018

<<<<<<< stretch-performance
**Execution Time:** 1.492 ms
**Scan Type:** Seq Scan on get_fit_now_check_in + Seq Scan on get_fit_now_member
**Join:** Hash Join
**Notes:** Filter removes 2693 rows from check_in — ⚠️ index on check_in_date would help

```
Sort  (cost=58.12..58.14 rows=10 width=28) (actual time=1.438..1.443 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=6.14..57.95 rows=10 width=28) (actual time=0.389..1.368 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..51.79 rows=10 width=14) (actual time=0.039..0.993 rows=10 loops=1)
               Filter: (check_in_date = 20180109)
               Rows Removed by Filter: 2693
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.309..0.310 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.019..0.121 rows=184 loops=1)
 Planning Time: 1.427 ms
 Execution Time: 1.492 ms
=======
**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
-- Paste EXPLAIN ANALYZE output here
>>>>>>> master
```

---

## Q4 — Gold gym members and their income

<<<<<<< stretch-performance
**Execution Time:** 4.902 ms
**Scan Type:** Seq Scan on person + Seq Scan on get_fit_now_member + Index Scan on income
**Join:** Hash Join + Nested Loop
**Notes:** income already uses Index Scan ✅ — person full scan is the target

```
Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=4.397..4.407 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.347..4.345 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.305..3.837 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.042..1.529 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.230..0.231 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.030..0.185 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.006..0.006 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 1.477 ms
 Execution Time: 4.902 ms
=======
**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
-- Paste EXPLAIN ANALYZE output here
>>>>>>> master
```

---

## Q5 — People who attended Facebook events in 2018

<<<<<<< stretch-performance
**Execution Time:** 29.551 ms
**Scan Type:** Seq Scan on facebook_event_checkin + Seq Scan on person
**Join:** Hash Join
**Notes:** Filter removes 14986 rows from facebook table — ⚠️ major optimization target

```
Sort  (cost=1159.80..1172.27 rows=4987 width=63) (actual time=26.651..27.856 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=321.25..853.50 rows=4987 width=63) (actual time=11.328..22.404 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..519.16 rows=4987 width=53) (actual time=0.020..6.588 rows=5025 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
               Rows Removed by Filter: 14986
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=11.267..11.268 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.012..4.620 rows=10011 loops=1)
 Planning Time: 0.704 ms
 Execution Time: 29.551 ms
=======
**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
-- Paste EXPLAIN ANALYZE output here
>>>>>>> master
```

---

## Q6 — Red-haired Tesla drivers

<<<<<<< stretch-performance
**Execution Time:** 7.677 ms
**Scan Type:** Seq Scan on person + Seq Scan on drivers_license
**Join:** Hash Join
**Notes:** Filter removes 10003 rows from drivers_license to find only 4 — ⚠️ optimization target

```
Sort  (cost=475.54..475.54 rows=2 width=40) (actual time=7.631..7.635 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..475.53 rows=2 width=40) (actual time=6.253..7.612 rows=4 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.014..1.284 rows=10011 loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=4.330..4.331 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.574..4.303 rows=4 loops=1)
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 0.410 ms
 Execution Time: 7.677 ms
=======
**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
-- Paste EXPLAIN ANALYZE output here
>>>>>>> master
```

---

## Q7 — Interview transcripts mentioning the gym or murder

<<<<<<< stretch-performance
**Execution Time:** 41.696 ms
**Scan Type:** Seq Scan on interview + Index Scan on person
**Join:** Nested Loop
**Notes:** ILIKE with wildcard '%gym%' prevents index use on transcript — ⚠️ cannot be optimized with B-tree index

```
Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=2.587..41.649 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=2.556..41.565 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.014..0.014 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 3.129 ms
 Execution Time: 41.696 ms
=======
**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
-- Paste EXPLAIN ANALYZE output here
>>>>>>> master
```

---

## Q8 — Average income by car make

<<<<<<< stretch-performance
**Execution Time:** 35.906 ms
**Scan Type:** Seq Scan on person + Seq Scan on income + Seq Scan on drivers_license
**Join:** Hash Join x2 + HashAggregate
**Notes:** Three large tables fully scanned — ⚠️ major optimization target

```
Sort  (cost=870.23..870.39 rows=65 width=55) (actual time=35.673..35.682 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.30..868.27 rows=65 width=55) (actual time=35.489..35.577 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7515 width=11) (actual time=22.299..32.126 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=9.225..15.693 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.016..1.597 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=9.192..9.193 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.011..1.856 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=11.703..11.704 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.016..2.373 rows=10007 loops=1)
 Planning Time: 1.284 ms
 Execution Time: 35.906 ms
```
=======
**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
-- Paste EXPLAIN ANALYZE output here
```
>>>>>>> master
