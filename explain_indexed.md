# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.311 ms (baseline: 0.220 ms | change: +0.09 ms)*
**Scan Type:** Index Scan
**Index Used:** idx_crime_city_type

```
 Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.212..0.214 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=0.153..0.164 rows=3 loops=1)
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 1.440 ms
 Execution Time: 0.311 ms
(7 rows)
```

---

## Q2 — People with their driver's license details

**Execution Time:** 32.186 ms (baseline: 21.917 ms | change: +10 ms)*
**Scan Type:** Seq Scan
**Index Used:** None

```
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=30.953..31.670 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=5.748..9.028 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.010..0.630 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=5.535..5.537 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.032..1.932 rows=10007 loops=1)
 Planning Time: 1.161 ms
 Execution Time: 32.186 ms
(11 rows)
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 31.059 ms (baseline: 1.204 ms | change: +29 ms)*
**Scan Type:** Bitmap Index Scan
**Index Used:** idx_checkin_date

```
 Sort  (cost=26.81..26.84 rows=10 width=28) (actual time=11.174..11.182 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=10.50..26.65 rows=10 width=28) (actual time=10.694..11.043 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Bitmap Heap Scan on get_fit_now_check_in ci  (cost=4.36..20.48 rows=10 width=14) (actual time=10.221..10.546 rows=10 loops=1)
               Recheck Cond: (check_in_date = 20180109)
               Heap Blocks: exact=8
               ->  Bitmap Index Scan on idx_checkin_date  (cost=0.00..4.36 rows=10 width=0) (actual time=10.121..10.123 rows=10 loops=1)
                     Index Cond: (check_in_date = 20180109)
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.390..0.392 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.017..0.178 rows=184 loops=1)
 Planning Time: 34.247 ms
 Execution Time: 31.059 ms
(15 rows)
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 4.430 ms (baseline: 5.908 ms | change: -1.47 ms)*
**Scan Type:** Index Scan
**Index Used:** idx_income_ssn

```
 Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=4.200..4.207 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.335..4.136 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.123..2.839 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.010..1.101 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.095..0.095 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.012..0.051 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using idx_income_ssn on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.018..0.018 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 1.854 ms
 Execution Time: 4.430 ms
(16 rows)
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 18.233 ms (baseline: 72.279 ms | change: -54 ms)*
**Scan Type:** Bitmap Index Scan
**Index Used:** idx_facebook_date

```
 Sort  (cost=1006.04..1018.51 rows=4989 width=63) (actual time=17.025..17.753 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=392.67..699.60 rows=4989 width=63) (actual time=5.566..14.052 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Bitmap Heap Scan on facebook_event_checkin fe  (cost=71.42..365.26 rows=4989 width=53) (actual time=0.508..6.258 rows=5025 loops=1)
               Recheck Cond: ((date >= 20180101) AND (date <= 20181231))
               Heap Blocks: exact=219
               ->  Bitmap Index Scan on idx_facebook_date  (cost=0.00..70.18 rows=4989 width=0) (actual time=0.468..0.469 rows=5025 loops=1)
                     Index Cond: ((date >= 20180101) AND (date <= 20181231))
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=4.829..4.830 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.010..1.746 rows=10011 loops=1)
 Planning Time: 1.175 ms
 Execution Time: 18.233 ms
(15 rows)
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 46.262 ms (baseline: 56.263 ms | change: -10 ms)*
**Scan Type:** Bitmap Index Scan / Index Scan
**Index Used:** idx_license_hair_car & idx_person_license

```
 Sort  (cost=28.13..28.14 rows=2 width=40) (actual time=46.212..46.214 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=34.177..46.192 rows=4 loops=1)
         ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=34.145..34.155 rows=4 loops=1)
               Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
               Heap Blocks: exact=4
               ->  Bitmap Index Scan on idx_license_hair_car  (cost=0.00..4.30 rows=2 width=0) (actual time=34.134..34.135 rows=4 loops=1)
                     Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
         ->  Index Scan using idx_person_license on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=3.001..3.004 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 0.709 ms
 Execution Time: 46.262 ms
(13 rows)
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 15.174 ms *(baseline: 70.200 ms | change: -55)*
**Scan Type:** Seq Scan (Filter)
**Index Used:** person_pkey (for Join)

```
 Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=1.086..15.101 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=1.052..14.952 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.031..0.031 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 3.464 ms
 Execution Time: 15.174 ms
(8 rows)
```

---

## Q8 — Average income by car make

**Execution Time:** 30.595 ms (baseline: 146.448 ms | change: -115.8 ms)*
**Scan Type:** Seq Scan / Hash Join
**Index Used:** N/A (Internal Hash Joins)

```
 Sort  (cost=870.19..870.36 rows=65 width=55) (actual time=30.066..30.080 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.26..868.24 rows=65 width=55) (actual time=28.371..29.869 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7512 width=11) (actual time=16.661..25.133 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=2.964..8.266 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.009..1.016 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=2.885..2.887 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.007..1.207 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=13.605..13.606 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.011..3.959 rows=10007 loops=1)
 Planning Time: 1.333 ms
 Execution Time: 30.595 ms
(19 rows)
```
