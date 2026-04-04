# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.220 ms
**Scan Type:** Seq Scan
**Join Method:** N/A (Single table query)


```
Sort  (cost=34.43..34.44 rows=1 width=53) (actual time=0.189..0.190 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=53) (actual time=0.021..0.171 rows=3 loops=1)
         Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
         Rows Removed by Filter: 1225
 Planning Time: 0.394 ms
 Execution Time: 0.220 ms
(8 rows)```

---

## Q2 — People with their driver's license details

**Execution Time:** 21.917 ms
**Scan Type:**  Seq Scan
**Join Method:** Hash Join

```
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=21.051..21.422 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=3.717..7.803 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.030..0.648 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=3.630..3.632 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.005..1.733 rows=10007 loops=1)
 Planning Time: 1.385 ms
 Execution Time: 21.917 ms
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 1.204 ms
**Scan Type:** Seq Scan
**Join Method:** Hash Join

```
 Sort  (cost=58.12..58.14 rows=10 width=28) (actual time=0.984..0.999 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=6.14..57.95 rows=10 width=28) (actual time=0.300..0.872 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..51.79 rows=10 width=14) (actual time=0.135..0.688 rows=10 loops=1)
               Filter: (check_in_date = 20180109)
               Rows Removed by Filter: 2693
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.144..0.144 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.006..0.048 rows=184 loops=1)
 Planning Time: 2.294 ms
 Execution Time: 1.204 ms
(13 rows)
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 5.908 ms
**Scan Type:** Seq Scan on person and get_fit_now_member, Index Scan on income.
Join Method: Hash Join & Nested Loop.
**Join Method:** Hash Join 

```
 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=5.851..5.861 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.323..5.490 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.259..3.922 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.045..1.132 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.123..0.124 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.017..0.056 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.022..0.022 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 0.780 ms
 Execution Time: 5.908 ms
(16 rows)
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 72.279 ms
**Scan Type:** Seq Scan
**Join Method:** Hash Join

```
 Sort  (cost=1159.80..1172.27 rows=4987 width=63) (actual time=71.465..72.112 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=321.25..853.50 rows=4987 width=63) (actual time=3.841..69.288 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..519.16 rows=4987 width=53) (actual time=0.058..63.406 rows=5025 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
               Rows Removed by Filter: 14986
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=3.427..3.428 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.009..1.159 rows=10011 loops=1)
 Planning Time: 0.729 ms
 Execution Time: 72.279 ms
(13 rows)
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 56.263 ms
**Scan Type:** Seq Scan 
**Join Method:** Hash Join

```
 Sort  (cost=475.54..475.54 rows=2 width=40) (actual time=56.110..56.114 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..475.53 rows=2 width=40) (actual time=45.522..46.852 rows=4 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.027..1.292 rows=10011 loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=43.075..43.076 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.779..43.047 rows=4 loops=1)
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 32.805 ms
 Execution Time: 56.263 ms
(13 rows)
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 70.200 ms
**Scan Type:** Seq Scan on interview i and Index Scan on person p
**Join Method:** Nested Loop

```
 Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=1.819..70.112 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=1.787..69.976 rows=4 loops=1)      
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.028..0.028 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 74.937 ms
 Execution Time: 70.200 ms
(8 rows)
```

---

## Q8 — Average income by car make

**Execution Time:** 146.448 ms
**Scan Type:** Seq Scan
**Join Method:** Hash Join (Double) & HashAggregate


```
 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=145.572..145.586 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=112.907..112.955 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=79.818..84.775 rows=7514 loops=1)     
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=72.665..76.065 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.032..0.766 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=72.490..72.491 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.015..69.459 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=6.960..6.961 rows=10007 loops=1)    
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.015..3.781 rows=10007 loops=1)
 Planning Time: 71.830 ms
 Execution Time: 146.448 ms
(19 rows)
```
