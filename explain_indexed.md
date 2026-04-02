# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.152 ms *(baseline: 0.441 ms | change: faster)*
**Scan Type:** Index Scan
**Index Used:** idx_crime_city_type

```
 Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.100..0.101 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=0.052..0.059 rows=3 loops=1)
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 0.605 ms
 Execution Time: 0.152 ms
```

---

## Q2 — People with their driver's license details

**Execution Time:** 15.785 ms *(baseline: 25.000 ms | change: 9.215 ms)*
**Scan Type:** Seq Scan + Hash Join
**Index Used:** None
```
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=15.226..15.514 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=2.760..5.287 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.003..0.409 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=2.699..2.700 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.003..1.250 rows=10007 loops=1)
 Planning Time: 0.774 ms
 Execution Time: 15.785 ms
```

---

## Q3 — Gym members who checked in on January 9, 2018


**Execution Time:** 0.695 ms *(baseline: 15.000 ms | change: 14.305 ms)*
**Scan Type:** Bitmap Heap Scan + Seq Scan + Hash Join
**Index Used:** idx_checkin_date
```
 Sort  (cost=26.81..26.84 rows=10 width=28) (actual time=0.589..0.591 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=10.50..26.65 rows=10 width=28) (actual time=0.282..0.558 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Bitmap Heap Scan on get_fit_now_check_in ci  (cost=4.36..20.48 rows=10 width=14) (actual time=0.149..0.417 rows=10 loops=1)
               Recheck Cond: (check_in_date = 20180109)
               Heap Blocks: exact=8
               ->  Bitmap Index Scan on idx_checkin_date  (cost=0.00..4.36 rows=10 width=0) (actual time=0.120..0.120 rows=10 loops=1)
                     Index Cond: (check_in_date = 20180109)
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.120..0.120 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.006..0.067 rows=184 loops=1)
 Planning Time: 1.651 ms
 Execution Time: 0.695 ms
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 2.826 ms *(baseline: 10.500 ms | change: 7.674 ms)*  
**Scan Type:** Nested Loop + Hash Join + Index Scan  
**Index Used:** idx_member_status, income_pkey
```
 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=2.773..2.776 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.154..2.727 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.069..1.309 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.003..0.431 rows=10011 loops=1)      
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.050..0.050 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.005..0.035 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.020..0.020 rows=1 loops=68) 
               Index Cond: (ssn = p.ssn)
 Planning Time: 1.872 ms
 Execution Time: 2.826 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 13.359 ms *(baseline: 45.200 ms | change: -31.841 ms)*  
**Scan Type:** Hash Join + Bitmap Heap Scan  
**Index Used:** idx_facebook_date, idx_facebook_person_id
```
 Sort  (cost=1006.04..1018.51 rows=4989 width=63) (actual time=12.538..13.087 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=392.67..699.60 rows=4989 width=63) (actual time=2.828..11.012 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Bitmap Heap Scan on facebook_event_checkin fe  (cost=71.42..365.26 rows=4989 width=53) (actual time=0.650..7.270 rows=5025 loops=1)
               Recheck Cond: ((date >= 20180101) AND (date <= 20181231))
               Heap Blocks: exact=219
               ->  Bitmap Index Scan on idx_facebook_date  (cost=0.00..70.18 rows=4989 width=0) (actual time=0.600..0.600 rows=5025 loops=1)
                     Index Cond: ((date >= 20180101) AND (date <= 20181231))
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=2.118..2.119 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.005..0.879 rows=10011 loops=1)     
 Planning Time: 1.897 ms
 Execution Time: 13.359 ms
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.653 ms *(baseline: 5.400 ms | change: -4.747 ms)*  
**Scan Type:** Nested Loop + Bitmap Heap Scan  
**Index Used:** idx_license_hair_car, idx_person_license_id

```
 Sort  (cost=28.13..28.14 rows=2 width=40) (actual time=0.578..0.580 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=0.293..0.531 rows=4 loops=1)
         ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=0.160..0.205 rows=4 loops=1)  
               Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
               Heap Blocks: exact=4
               ->  Bitmap Index Scan on idx_license_hair_car  (cost=0.00..4.30 rows=2 width=0) (actual time=0.146..0.146 rows=4 loops=1)
                     Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
         ->  Index Scan using idx_person_license_id on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.077..0.078 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 1.769 ms
 Execution Time: 0.653 ms
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 8.562 ms *(baseline: 95.230 ms | change: -86.668 ms)*  
**Scan Type:** Nested Loop + Seq Scan  
**Index Used:** person_pkey
```
Nested Loop (cost=0.29..134.17 rows=1 width=61) (actual time=0.579..8.538 rows=4 loops=1) -> Seq Scan on interview i (cost=0.00..125.86 rows=1 width=51) (actual time=0.563..8.485 rows=4 loops=1) Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text)) Rows Removed by Filter: 4987 -> Index Scan using person_pkey on person p (cost=0.29..8.30 rows=1 width=18) (actual time=0.011..0.011 rows=1 loops=4) Index Cond: (id = i.person_id) Planning Time: 1.789 ms Execution Time: 8.562 ms
```

---

## Q8 — Average income by car make

**Execution Time:** 9.040 ms *(baseline: 42.520 ms | change: -33.480 ms)*  
**Scan Type:** Hash Join + Seq Scan  
**Index Used:** idx_person_license_id, idx_person_ssn

```
Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=8.781..8.785 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=8.639..8.661 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=4.326..7.421 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=2.017..4.179 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.005..0.447 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=1.983..1.984 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.008..1.159 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=2.254..2.255 rows=10007 loops=1 s=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=2.254..2.255 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.004..1.147 rows=10007 loops=1)
 Planning Time: 1.090 ms
 Execution Time: 9.040 ms               
```
