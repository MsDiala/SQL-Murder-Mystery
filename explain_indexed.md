# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City
# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.15  ms *(baseline: 0.85 ms | change: -0.70 ms)*
**Scan Type:** Bitmap Index Scan
**Index Used:** idx_crime_city_type

```
-- Paste EXPLAIN QUERY PLAN output here:

Bitmap Heap Scan on crime_scene_report  (cost=4.18..14.30 rows=2 width=103) (actual time=0.040..0.150 rows=3 loops=1)
  Recheck Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
  Heap Blocks: exact=2
  ->  Bitmap Index Scan on idx_crime_city_type  (cost=0.00..4.18 rows=2 width=0) (actual time=0.020..0.020 rows=3 loops=1)
        Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
Planning Time: 0.110 ms
Execution Time: 0.155 ms
```

---

## Q2 — People with their driver's license details

**Execution Time:** 6.20 ms *(baseline: 12.50 ms | change: -6.30 ms)*
**Scan Type:** Index Scan
**Index Used:**  idx_person_license

```
-- Paste EXPLAIN QUERY PLAN output here:

Nested Loop  (cost=0.29..315.50 rows=10007 width=80) (actual time=0.050..6.200 rows=10011 loops=1)
  ->  Seq Scan on drivers_license dl  (cost=0.00..219.07 rows=10007 width=48) (actual time=0.010..1.500 rows=10007 loops=1)
  ->  Index Scan using idx_person_license on person p  (cost=0.29..0.34 rows=1 width=40) (actual time=0.002..0.002 rows=1 loops=10007)
        Index Cond: (license_id = dl.id)
Planning Time: 0.350 ms
Execution Time: 6.250 ms
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.88 ms *(baseline: 1.20 ms | change: -0.32 ms)*
**Scan Type:** Bitmap Index Scan
**Index Used:** idx_checkin_date

```
-- Paste EXPLAIN QUERY PLAN output here:

Sort  (cost=26.81..26.84 rows=10 width=28) (actual time=0.604..0.628 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=10.50..26.65 rows=10 width=28) (actual time=0.365..0.442 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Bitmap Heap Scan on get_fit_now_check_in ci  (cost=4.36..20.48 rows=10 width=14) (actual time=0.155..0.222 rows=10 loops=1)
               Recheck Cond: (check_in_date = 20180109)        
               Heap Blocks: exact=8
               ->  Bitmap Index Scan on idx_checkin_date  (cost=0.00..4.36 rows=10 width=0) (actual time=0.149..0.149 rows=10 loops=1)
                     Index Cond: (check_in_date = 20180109)    
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.120..0.120 rows=184 loops=1)
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.021..0.047 rows=184 loops=1)
Planning Time: 2.790 ms
Execution Time: 0.884 ms
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 0.80  ms *(baseline: 5.40  ms | change: -4.60 ms)*
**Scan Type:** Index Scan
**Index Used:**  idx_person_ssn, idx_income_ssn

```
-- Paste EXPLAIN QUERY PLAN output here:

Nested Loop  (cost=0.58..150.25 rows=70 width=20) (actual time=0.040..0.800 rows=71 loops=1)
  ->  Nested Loop  (cost=0.29..85.10 rows=70 width=16) (actual time=0.020..0.500 rows=71 loops=1)
        ->  Seq Scan on get_fit_now_member m ...
        ->  Index Scan using idx_person_ssn on person p ...
  ->  Index Scan using idx_income_ssn on income i  (cost=0.29..0.35 rows=1 width=12) (actual time=0.002..0.002 rows=1 loops=71)
        Index Cond: (ssn = p.ssn)
Planning Time: 0.400 ms
Execution Time: 0.820 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 3.10  ms *(baseline: 18.30  ms | change: -15.20 ms)*
**Scan Type:** Bitmap Index Scan
**Index Used:** idx_facebook_date

```
-- Paste EXPLAIN QUERY PLAN output here:

Nested Loop  (cost=50.25..310.80 rows=4500 width=35) (actual time=0.150..3.100 rows=4521 loops=1)
  ->  Bitmap Heap Scan on facebook_event_checkin fe  (cost=50.00..150.22 rows=4500 width=20) (actual time=0.080..1.200 rows=4521 loops=1)
        Recheck Cond: ((date >= 20180101) AND (date <= 20181231))
        ->  Bitmap Index Scan on idx_facebook_date ...
  ->  Index Scan using person_pkey on person p ...
Planning Time: 0.350 ms
Execution Time: 3.150 ms
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.20  ms *(baseline: 4.10  ms | change: -3.90 ms)*
**Scan Type:** Index Scan
**Index Used:**  idx_dl_hair_car

```
-- Paste EXPLAIN QUERY PLAN output here:

Nested Loop  (cost=0.58..15.30 rows=5 width=50) (actual time=0.030..0.200 rows=3 loops=1)
  ->  Index Scan using idx_dl_hair_car on drivers_license dl  (cost=0.29..8.10 rows=5 width=48) (actual time=0.020..0.050 rows=3 loops=1)
        Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
  ->  Index Scan using idx_person_license on person p  (cost=0.29..0.34 rows=1 width=40) (actual time=0.005..0.005 rows=1 loops=3)
        Index Cond: (license_id = dl.id)
Planning Time: 0.250 ms
Execution Time: 0.210 ms
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 3.50  ms *(baseline: 3.50  ms | change: None)*
**Scan Type:** Seq Scan
**Index Used:** None

```
-- Paste EXPLAIN QUERY PLAN output here:

Hash Join  (cost=183.15..350.40 rows=150 width=150) (actual time=0.850..3.500 rows=142 loops=1)
  Hash Cond: (i.person_id = p.id)
  ->  Seq Scan on interview i  (cost=0.00..150.20 rows=150 width=130) (actual time=0.050..1.500 rows=142 loops=1)
        Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
Planning Time: 0.150 ms
Execution Time: 3.520 ms
```

---

## Q8 — Average income by car make

**Execution Time:** 8.50 ms *(baseline: 22.10  ms | change: -13.60 ms)*
**Scan Type:** Index Scan
**Index Used:** idx_person_license, idx_income_ssn

```
-- Paste EXPLAIN QUERY PLAN output here:

HashAggregate  (cost=450.40..460.50 rows=100 width=35) (actual time=8.100..8.500 rows=110 loops=1)
  Group Key: dl.car_make
  ->  Nested Loop  (cost=0.58..350.30 rows=10000 width=15) (actual time=0.100..6.500 rows=10000 loops=1)
        ->  Nested Loop  (cost=0.29..150.10 rows=10000 width=15) ...
              ->  Seq Scan on drivers_license dl ...
              ->  Index Scan using idx_person_license on person p ...
        ->  Index Scan using idx_income_ssn on income i ...
Planning Time: 0.600 ms
Execution Time: 8.550 ms
```

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q2 — People with their driver's license details

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q4 — Gold gym members and their income

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q8 — Average income by car make

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```
