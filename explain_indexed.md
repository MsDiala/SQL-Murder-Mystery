# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 1.170 ms *(baseline: 0.453 ms | change: slower due to planning overhead)*
**Scan Type:** Index Scan
**Index Used:** idx_crime_city_type

```
Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.281..0.314 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=0.191..0.207 rows=3 loops=1)
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 9.508 ms
 Execution Time: 1.170 ms
```

---

## Q2 — People with their driver's license details

**Execution Time:** 65.324 ms *(baseline: 63.802 ms | change: no improvement)*
**Scan Type:** Seq Scan on person + Seq Scan on drivers_license
**Index Used:** None — planner chose Seq Scan (full table join, index not beneficial)

```
Sort  (cost=1215.75..1240.78 rows=10011 width=60) (actual time=62.560..63.910 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10011 width=60) (actual time=15.512..26.617 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.014..2.207 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=15.155..15.157 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.020..8.061 rows=10007 loops=1)
 Planning Time: 7.154 ms
 Execution Time: 65.324 ms
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 1.714 ms *(baseline: 1.492 ms | change: scan type improved)*
**Scan Type:** Bitmap Index Scan on get_fit_now_check_in
**Index Used:** idx_checkin_date_membership

```
Sort  (cost=26.81..26.84 rows=10 width=28) (actual time=1.323..1.327 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=10.50..26.65 rows=10 width=28) (actual time=1.070..1.256 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Bitmap Heap Scan on get_fit_now_check_in ci  (cost=4.36..20.48 rows=10 width=14) (actual time=0.571..0.739 rows=10 loops=1)
               Recheck Cond: (check_in_date = 20180109)
               Heap Blocks: exact=8
               ->  Bitmap Index Scan on idx_checkin_date_membership  (cost=0.00..4.36 rows=10 width=0) (actual time=0.466..0.467 rows=10 loops=1)
                     Index Cond: (check_in_date = 20180109)
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.467..0.468 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.021..0.215 rows=184 loops=1)
 Planning Time: 5.775 ms
 Execution Time: 1.714 ms
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 11.212 ms *(baseline: 4.902 ms | change: no improvement — small tables)*
**Scan Type:** Seq Scan on person + Seq Scan on get_fit_now_member + Index Scan on income
**Index Used:** income_pkey (already existed)

```
Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=10.897..10.907 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.387..10.798 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.095..3.385 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.010..1.369 rows=10011 loops=1)
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.067..0.068 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.013..0.047 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.107..0.107 rows=1 loops=68)
               Index Cond: (ssn = p.ssn)
 Planning Time: 3.323 ms
 Execution Time: 11.212 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 50.456 ms *(baseline: 29.551 ms | change: scan type improved but overall slower)*
**Scan Type:** Bitmap Index Scan on facebook_event_checkin
**Index Used:** idx_facebook_date

```
Sort  (cost=1006.04..1018.51 rows=4989 width=63) (actual time=49.215..49.865 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=392.67..699.60 rows=4989 width=63) (actual time=17.845..45.010 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Bitmap Heap Scan on facebook_event_checkin fe  (cost=71.42..365.26 rows=4989 width=53) (actual time=1.553..24.340 rows=5025 loops=1)
               Recheck Cond: ((date >= 20180101) AND (date <= 20181231))
               Heap Blocks: exact=219
               ->  Bitmap Index Scan on idx_facebook_date  (cost=0.00..70.18 rows=4989 width=0) (actual time=1.429..1.430 rows=5025 loops=1)
                     Index Cond: ((date >= 20180101) AND (date <= 20181231))
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=16.256..16.257 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.017..7.962 rows=10011 loops=1)
 Planning Time: 6.874 ms
 Execution Time: 50.456 ms
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 3.287 ms *(baseline: 7.677 ms | change: -57% ✅ major improvement)*
**Scan Type:** Bitmap Index Scan on drivers_license + Index Scan on person
**Index Used:** idx_license_hair_car + idx_person_license_id

```
Sort  (cost=28.13..28.14 rows=2 width=40) (actual time=3.213..3.219 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=2.449..3.181 rows=4 loops=1)
         ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=2.116..2.179 rows=4 loops=1)
               Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
               Heap Blocks: exact=4
               ->  Bitmap Index Scan on idx_license_hair_car  (cost=0.00..4.30 rows=2 width=0) (actual time=2.078..2.079 rows=4 loops=1)
                     Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
         ->  Index Scan using idx_person_license_id on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.240..0.242 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 0.644 ms
 Execution Time: 3.287 ms
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 30.111 ms *(baseline: 41.696 ms | change: -28% slight improvement)*
**Scan Type:** Seq Scan on interview + Index Scan on person
**Index Used:** person_pkey (already existed) — ILIKE wildcard prevents index on transcript

```
Nested Loop  (cost=0.29..134.17 rows=1 width=61) (actual time=1.529..29.944 rows=4 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..125.86 rows=1 width=51) (actual time=1.512..29.795 rows=4 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
         Rows Removed by Filter: 4987
   ->  Index Scan using person_pkey on person p  (cost=0.29..8.30 rows=1 width=18) (actual time=0.030..0.030 rows=1 loops=4)
         Index Cond: (id = i.person_id)
 Planning Time: 4.303 ms
 Execution Time: 30.111 ms
```

---

## Q8 — Average income by car make

**Execution Time:** 38.588 ms *(baseline: 35.906 ms | change: no improvement)*
**Scan Type:** Seq Scan on person + Seq Scan on income + Seq Scan on drivers_license
**Index Used:** None — planner chose Seq Scan (aggregation over full tables)

```
Sort  (cost=870.23..870.39 rows=65 width=55) (actual time=37.919..37.929 rows=64 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=867.30..868.27 rows=65 width=55) (actual time=37.373..37.461 rows=64 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..773.36 rows=7515 width=11) (actual time=17.042..31.451 rows=7514 loops=1)
               Hash Cond: (p.license_id = dl.id)
               ->  Hash Join  (cost=203.06..425.47 rows=7515 width=8) (actual time=7.712..17.096 rows=7514 loops=1)
                     Hash Cond: (p.ssn = i.ssn)
                     ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.019..1.954 rows=10011 loops=1)
                     ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=7.669..7.670 rows=7514 loops=1)
                           Buckets: 8192  Batches: 1  Memory Usage: 358kB
                           ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.011..3.761 rows=7514 loops=1)
               ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=9.081..9.081 rows=10007 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 567kB
                     ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.017..3.898 rows=10007 loops=1)
 Planning Time: 2.490 ms
 Execution Time: 38.588 ms
```