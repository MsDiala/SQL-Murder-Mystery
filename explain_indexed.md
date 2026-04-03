# explain_indexed.md — After Indexing

> Re-run the same EXPLAIN ANALYZE queries after adding your indexes.
> Compare the results to your baseline.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.164 ms (was 0.314 ms)
**Scan Type:** Index Scan
**Join Method:** None

```sql
                                                                  QUERY PLAN                                                                   
-----------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=8.31..8.31 rows=1 width=52) (actual time=0.112..0.114 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=52) (actual time=0.074..0.082 rows=3 loops=1)
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 0.650 ms
 Execution Time: 0.164 ms
```

---

## Q2 — People with their driver's license details

**Execution Time:** 50.927 ms (was 47.013 ms)
**Scan Type:** Seq Scan
**Join Method:** Hash Join

```sql
                                                               QUERY PLAN                                                                
-----------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=49.050..50.294 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=6.250..11.829 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.006..0.999 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=6.144..6.146 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.006..2.409 rows=10007 loops=1)
 Planning Time: 0.858 ms
 Execution Time: 50.927 ms
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.209 ms (was 0.450 ms)
**Scan Type:** Bitmap Index Scan, Bitmap Heap Scan, Seq Scan
**Join Method:** Hash Join

```sql
                                                               QUERY PLAN                                                                
-----------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=26.81..26.84 rows=10 width=28) (actual time=0.179..0.181 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=10.50..26.65 rows=10 width=28) (actual time=0.142..0.166 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Bitmap Heap Scan on get_fit_now_check_in ci  (cost=4.36..20.48 rows=10 width=14) (actual time=0.032..0.050 rows=10 loops=1)
               Recheck Cond: (check_in_date = 20180109)
               Heap Blocks: exact=8
               ->  Bitmap Index Scan on idx_checkin_date  (cost=0.00..4.36 rows=10 width=0) (actual time=0.027..0.027 rows=10 loops=1)
                     Index Cond: (check_in_date = 20180109)
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.101..0.101 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.008..0.047 rows=184 loops=1)
 Planning Time: 0.823 ms
 Execution Time: 0.209 ms
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 2.727 ms (was 2.710 ms)
**Scan Type:** Seq Scan, Index Scan
**Join Method:** Nested Loop, Hash Join

```sql
                                                               QUERY PLAN                                                                
-----------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=2.695..2.701 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.088..2.668 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.079..2.459 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.005..0.934 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.059..0.059 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.006..0.040 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.002..0.003 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 0.602 ms
 Execution Time: 2.727 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 10.309 ms (was 11.803 ms)
**Scan Type:** Bitmap Index Scan, Bitmap Heap Scan, Seq Scan
**Join Method:** Hash Join

```sql
                                                                    QUERY PLAN                                                                    
-------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=1004.04..1016.51 rows=4989 width=62) (actual time=9.432..9.912 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 718kB
   ->  Hash Join  (cost=392.67..697.60 rows=4989 width=62) (actual time=4.300..7.436 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Bitmap Heap Scan on facebook_event_checkin fe  (cost=71.42..363.26 rows=4989 width=52) (actual time=0.399..1.662 rows=5025 loops=1)
               Recheck Cond: ((date >= 20180101) AND (date <= 20181231))
               Heap Blocks: exact=217
               ->  Bitmap Index Scan on idx_facebook_date  (cost=0.00..70.18 rows=4989 width=0) (actual time=0.361..0.361 rows=5025 loops=1)
                     Index Cond: ((date >= 20180101) AND (date <= 20181231))
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=3.887..3.888 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.004..1.614 rows=10011 loops=1)
 Planning Time: 0.527 ms
 Execution Time: 10.309 ms
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.145 ms (was 4.100 ms)
**Scan Type:** Bitmap Index Scan, Bitmap Heap Scan, Index Scan
**Join Method:** Nested Loop

```sql
                                                                 QUERY PLAN                                                                  
---------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=28.13..28.14 rows=2 width=40) (actual time=0.119..0.120 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=0.065..0.110 rows=4 loops=1)
         ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=0.047..0.052 rows=4 loops=1)
               Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
               Heap Blocks: exact=4
               ->  Bitmap Index Scan on idx_license_hair_car  (cost=0.00..4.30 rows=2 width=0) (actual time=0.043..0.043 rows=4 loops=1)
                     Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
         ->  Index Scan using idx_person_license_id on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.012..0.013 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 0.277 ms
 Execution Time: 0.145 ms
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 15.953 ms (was 15.964 ms)
**Scan Type:** Seq Scan, Index Scan
**Join Method:** Nested Loop

```sql
                                                         QUERY PLAN                                                          
-----------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.29..134.17 rows=1 width=60) (actual time=0.869..15.936 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=50) (actual time=0.860..15.913 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.004..0.004 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 1.378 ms
 Execution Time: 15.953 ms
```

---

## Q8 — Average income by car make

**Execution Time:** 16.558 ms (was 16.495 ms)
**Scan Type:** Seq Scan
**Join Method:** HashAggregate, Hash Join

```sql
                                                                  QUERY PLAN                                                                   
-----------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=16.500..16.507 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=16.391..16.442 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=7.333..13.866 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=2.774..7.260 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.005..1.070 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=2.760..2.761 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.005..1.159 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=4.475..4.476 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.004..2.093 rows=10007 loops=1)
 Planning Time: 0.492 ms
 Execution Time: 16.558 ms
```
