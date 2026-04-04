# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.446 ms
**Scan Type:** Seq Scan on crime_scene_report
**Join Method:** None

```
 Sort  (cost=34.43..34.44 rows=1 width=53) (actual time=0.399..0.400 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=53) (actual time=0.091..0.366 rows=3 loops=1)  
         Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
         Rows Removed by Filter: 1225
 Planning Time: 0.397 ms
 Execution Time: 0.446 ms
(8 rows)
```

---

## Q2 — People with their driver's license details

**Execution Time:** 23.207 ms
**Scan Type:** Seq Scan on person p 
**Join Method:** Hash Join

```
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=22.292..22.788 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=5.969..9.464 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.010..0.659 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=5.839..5.841 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.008..3.277 rows=10007 loops=1)
 Planning Time: 1.218 ms
 Execution Time: 23.207 ms
(11 rows)
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.622 ms
**Scan Type:** Seq Scan on get_fit_now_check_in ci
**Join Method:** Hash Join

```
 Sort  (cost=58.12..58.14 rows=10 width=28) (actual time=0.532..0.544 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=6.14..57.95 rows=10 width=28) (actual time=0.148..0.498 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..51.79 rows=10 width=14) (actual time=0.049..0.384 rows=10 loops=1)
               Filter: (check_in_date = 20180109)
               Rows Removed by Filter: 2693
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.084..0.085 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.005..0.040 rows=184 loops=1)
 Planning Time: 1.591 ms
 Execution Time: 0.622 ms
(13 rows)
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 1.687 ms
**Scan Type:** Seq Scan on person p / Seq Scan on get_fit_now_member m
**Join Method:** Nested Loop / Hash Join

```
 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=1.612..1.617 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.100..1.574 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.090..1.390 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.006..0.487 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.070..0.070 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.006..0.047 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)      
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.002..0.002 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 1.075 ms
 Execution Time: 1.687 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 7.582 ms
**Scan Type:** Seq Scan on facebook_event_checkin fe / Seq Scan on person p
**Join Method:** Hash Join

```
 Sort  (cost=1159.80..1172.27 rows=4987 width=63) (actual time=7.051..7.342 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=321.25..853.50 rows=4987 width=63) (actual time=2.945..5.838 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..519.16 rows=4987 width=53) (actual time=0.018..2.112 rows=5025 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
               Rows Removed by Filter: 14986
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=2.839..2.840 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.003..1.202 rows=10011 loops=1)
 Planning Time: 0.747 ms
 Execution Time: 7.582 ms
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 2.196 ms
**Scan Type:** Seq Scan on drivers_license dl / Seq Scan on person p
**Join Method:** Hash Join

```
 Sort  (cost=475.54..475.54 rows=2 width=40) (actual time=2.147..2.149 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..475.53 rows=2 width=40) (actual time=1.542..2.122 rows=4 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.004..0.461 rows=10011 loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=0.928..0.929 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.108..0.923 rows=4 loops=1)
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 0.858 ms
 Execution Time: 2.196 ms
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 8.472 ms
**Scan Type:** Seq Scan on interview i / Index Scan on person p
**Join Method:** Nested Loop

```
 Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=0.582..8.423 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=0.569..8.374 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.010..0.010 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 1.873 ms
 Execution Time: 8.472 ms
```

---

## Q8 — Average income by car make

**Execution Time:** 8.689 ms
**Scan Type:** Seq Scan on person p / Seq Scan on income i / Seq Scan on drivers_license dl
**Join Method:** Hash Join

```
 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=8.456..8.461 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=8.337..8.360 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=3.994..7.092 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=1.746..3.914 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.005..0.488 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=1.711..1.712 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB  
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.018..0.915 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=2.188..2.188 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB       
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.003..1.059 rows=10007 loops=1)        
 Planning Time: 1.371 ms
 Execution Time: 8.689 ms
```

