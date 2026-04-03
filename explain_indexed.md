# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 3.763 ms *(baseline: 0.462 ms | change: +3.301 ms)*
**Scan Type:** Index Scan
**Index Used:** idx_crime_city_type
```
-- Paste EXPLAIN QUERY PLAN output here
```sql
Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=2.667..2.668 rows=3 loops=1)
  Sort Key: date DESC
  Sort Method: quicksort  Memory: 25kB
  ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=1.985..2.616 rows=3 loops=1)
        Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
Planning Time: 35.331 ms
Execution Time: 3.763 ms

---

## Q2 — People with their driver's license details

**Execution Time:** __34.129_ ms *(baseline: __34.129_ ms | change: __0ms_)*
**Scan Type:** _Seq Scan on `person`, Seq Scan on `drivers_license`__
**Index Used:** _None__

```
-- Paste EXPLAIN QUERY PLAN output here
```sql
Sort  (cost=1002.51..1021.29 rows=7511 width=60) (actual time=33.398..33.756 rows=7511 loops=1)
  Sort Key: p.name
  Sort Method: quicksort  Memory: 997kB
  ->  Hash Join  (cost=328.16..519.00 rows=7511 width=60) (actual time=12.912..19.779 rows=7511 loops=1)
        Hash Cond: (p.license_id = dl.id)
        ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=36) (actual time=1.992..7.363 rows=7511 loops=1)
        ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=10.787..10.788 rows=10007 loops=1)
              Buckets: 16384  Batches: 1  Memory Usage: 793kB
              ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.941..7.463 rows=10007 loops=1)
Planning Time: 30.961 ms
Execution Time: 34.129 ms

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** _1.630__ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** _Seq Scan__
**Index Used:** _None__

```
-- Paste EXPLAIN QUERY PLAN output here
```sql
Nested Loop  (cost=0.00..0.01 rows=1 width=72) (actual time=0.006..0.007 rows=0 loops=1)
  ->  Seq Scan on get_fit_now_member m  (actual time=0.006..0.006 rows=0 loops=1)
  ->  Seq Scan on get_fit_now_check_in ci  (never executed)
        Filter: (check_in_date = 20180109)
Planning Time: 2.078 ms
Execution Time: 1.630 ms

---

## Q4 — Gold gym members and their income

**Execution Time:** __0.075 _ ms *(baseline: _0.075_ ms | change: _0 ms__)*
**Scan Type:** _Seq Scan on `get_fit_now_member__
**Index Used:** _None__

```
-- Paste EXPLAIN QUERY PLAN output here
```sql
Nested Loop  (cost=0.56..8.63 rows=1 width=68) (actual time=0.004..0.005 rows=0 loops=1)
  ->  Seq Scan on get_fit_now_member m
        Filter: (membership_status = 'gold')
  ->  Index Scan using person_pkey on person p (never executed)
  ->  Index Scan using income_pkey on income i (never executed)
Planning Time: 6.905 ms
Execution Time: 0.075 ms

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** _0.023_ ms *(baseline: _0.023__ ms | change: _0 ms__)*
**Scan Type:** _Seq Scan on facebook_event_checkin__
**Index Used:** _None__

```
-- Paste EXPLAIN QUERY PLAN output here
```Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.005..0.005 rows=0 loops=1)
  ->  Seq Scan on facebook_event_checkin fe
        Filter: ((date >= 20180101) AND (date <= 20181231))
  ->  Index Scan using person_pkey on person p (never executed)
Planning Time: 2.992 ms
Execution Time: 0.023 ms

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** _5.013__ ms *(baseline: _5.013__ ms | change: _0 ms)*
**Scan Type:** _Seq Scan on `drivers_license`, Index Scan on `person__
**Index Used:** _idx_person_license__

```
-- Paste EXPLAIN QUERY PLAN output here
```sql
Nested Loop  (cost=0.28..269.72 rows=2 width=40) (actual time=1.548..4.945 rows=3 loops=1)
  ->  Seq Scan on drivers_license dl
        Filter: ((hair_color = 'red') AND (car_make = 'Tesla'))
        Rows Removed by Filter: 10003
  ->  Index Scan using idx_person_license on person p
        Index Cond: (license_id = dl.id)
Planning Time: 0.486 ms
Execution Time: 5.013 ms

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** _0.021 __ ms *(baseline: _0.021 __ ms | change: _0ms__)*
**Scan Type:** _Seq Scan on `interview`__
**Index Used:** _None__

```
-- Paste EXPLAIN QUERY PLAN output here
```
sql
Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.004..0.005 rows=0 loops=1)
  ->  Seq Scan on interview i
        Filter: ((transcript ~~* '%gym%') OR (transcript ~~* '%murder%'))
  ->  Index Scan using person_pkey on person p (never executed)
Planning Time: 0.280 ms
Execution Time: 0.021 ms

---

## Q8 — Average income by car make

**Execution Time:** _ 11.720__ ms *(baseline: 11.720 ms | change: __0ms_)*
**Scan Type:** _Seq Scan on `person`, `drivers_license`, `income`__
**Index Used:** __None_

```
-- Paste EXPLAIN QUERY PLAN output here
```
sql
HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=10.500..10.551 rows=62 loops=1)
  Group Key: dl.car_make
  ->  Hash Join
        ->  Hash Join
              ->  Seq Scan on person p
              ->  Seq Scan on drivers_license dl
        ->  Seq Scan on income i
Planning Time: 8.663 ms
Execution Time: 11.720 ms