# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.500 ms
**Scan Type:** Seq Scan 
**Notes:** Filters by city and type, then sorts by date descending.

```
 Sort  (cost=34.43..34.44 rows=1 width=53) (actual time=0.457..0.458 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=53) (actual time=0.019..0.416 rows=3 loops=1)
         Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
         Rows Removed by Filter: 1225
 Planning Time: 0.719 ms
 Execution Time: 0.500 ms
(8 rows)

```

---

## Q2 — People with their driver's license details

**Execution Time:** 17.644 ms
**Scan Type:** Seq Scan + Hash Join
**Notes:** PostgreSQL performed a sequential scan on both `person` and `drivers_license`, then used a hash join on `license_id = id`, and finally sorted the results by `p.name`.

```
 Sort  (cost=1002.51..1021.29 rows=7511 width=60) (actual time=17.046..17.383 rows=7511 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 997kB
   ->  Hash Join  (cost=328.16..519.00 rows=7511 width=60) (actual time=5.015..7.423 rows=7511 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=36) (actual time=0.006..0.481 rows=7511 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=4.931..4.932 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.022..1.955 rows=10007 loops=1)
 Planning Time: 0.161 ms
 Execution Time: 17.644 ms
(11 rows)
```
---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.089 ms  
**Scan Type:** Seq Scan + Nested Loop  
**Notes:** PostgreSQL planned a nested loop join, with a sequential scan on `get_fit_now_member` and a filtered sequential scan on `get_fit_now_check_in`. This query returned 0 rows in the current Postgres dataset.

```sql
Sort  (cost=0.02..0.03 rows=1 width=72) (actual time=0.013..0.014 rows=0 loops=1)
  Sort Key: ci.check_in_time
  Sort Method: quicksort  Memory: 25kB
  ->  Nested Loop  (cost=0.00..0.01 rows=1 width=72) (actual time=0.006..0.006 rows=0 loops=1)
        Join Filter: (m.id = ci.membership_id)
        ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=96) (actual time=0.005..0.006 rows=0 loops=1)
        ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..0.00 rows=1 width=40) (never executed)
              Filter: (check_in_date = 20180109)
Planning Time: 0.449 ms
Execution Time: 0.089 ms
```
---

## Q4 — Gold gym members and their income

**Execution Time:** 0.082 ms  
**Scan Type:** Seq Scan + Index Scan + Nested Loop  
**Notes:** PostgreSQL first performed a sequential scan on `get_fit_now_member` to filter `membership_status = 'gold'`. Because no rows matched, the later index scans on `person` and `income` were never executed.

```sql
Sort  (cost=8.64..8.65 rows=1 width=68) (actual time=0.009..0.010 rows=0 loops=1)
  Sort Key: i.annual_income DESC
  Sort Method: quicksort  Memory: 25kB
  ->  Nested Loop  (cost=0.56..8.63 rows=1 width=68) (actual time=0.005..0.005 rows=0 loops=1)
        ->  Nested Loop  (cost=0.28..8.30 rows=1 width=68) (actual time=0.004..0.005 rows=0 loops=1)
              ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=68) (actual time=0.004..0.004 rows=0 loops=1)
                    Filter: (membership_status = 'gold'::text)
              ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=8) (never executed)
                    Index Cond: (id = m.person_id)
        ->  Index Scan using income_pkey on income i  (cost=0.28..0.33 rows=1 width=8) (never executed)
              Index Cond: (ssn = p.ssn)
Planning Time: 0.636 ms
Execution Time: 0.082 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 0.276 ms  
**Scan Type:** Seq Scan + Index Scan + Nested Loop  
**Notes:** PostgreSQL performed a sequential scan on `facebook_event_checkin` to filter the date range, then planned an index scan on `person` using the primary key. No rows matched the date filter, so the join to `person` was never executed.

```sql
Sort  (cost=8.31..8.32 rows=1 width=50) (actual time=0.054..0.069 rows=0 loops=1)
  Sort Key: fe.date DESC
  Sort Method: quicksort  Memory: 25kB
  ->  Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.004..0.005 rows=0 loops=1)
        ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..0.00 rows=1 width=40) (actual time=0.004..0.004 rows=0 loops=1)
              Filter: ((date >= 20180101) AND (date <= 20181231))
        ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
              Index Cond: (id = fe.person_id)
Planning Time: 0.648 ms
Execution Time: 0.276 ms
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 2.339 ms  
**Scan Type:** Seq Scan + Hash Join  
**Notes:** PostgreSQL performed a sequential scan on `drivers_license` to filter `hair_color = 'red'` and `car_make = 'Tesla'`, then used a hash join with `person` on `license_id = id`, and finally sorted the result by `p.name`.

```sql
Sort  (cost=443.98..443.98 rows=2 width=40) (actual time=2.318..2.320 rows=3 loops=1)
  Sort Key: p.name
  Sort Method: quicksort  Memory: 25kB
  ->  Hash Join  (cost=253.13..443.97 rows=2 width=40) (actual time=1.723..2.290 rows=3 loops=1)
        Hash Cond: (p.license_id = dl.id)
        ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=18) (actual time=0.005..0.384 rows=7511 loops=1)
        ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=1.260..1.261 rows=4 loops=1)
              Buckets: 1024  Batches: 1  Memory Usage: 9kB
              ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.175..1.205 rows=4 loops=1)
                    Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                    Rows Removed by Filter: 10003
Planning Time: 0.262 ms
Execution Time: 2.339 ms
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 0.075 ms  
**Scan Type:** Seq Scan + Index Scan + Nested Loop  
**Notes:** PostgreSQL performed a sequential scan on `interview` to evaluate the `LIKE '%gym%'` and `LIKE '%murder%'` conditions, then planned an index scan on `person` using the primary key. No rows matched, so the join to `person` was never executed.

```sql
Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.004..0.005 rows=0 loops=1)
  ->  Seq Scan on interview i  (cost=0.00..0.00 rows=1 width=36) (actual time=0.004..0.005 rows=0 loops=1)
        Filter: ((transcript ~~ '%gym%'::text) OR (transcript ~~ '%murder%'::text))
  ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
        Index Cond: (id = i.person_id)
Planning Time: 0.474 ms
Execution Time: 0.075 ms
```

---
## Q8 — Average income by car make

**Execution Time:** 10.161 ms  
**Scan Type:** Seq Scan + Hash Join + HashAggregate  
**Notes:** PostgreSQL performed sequential scans on `person`, `drivers_license`, and `income`, then used hash joins to combine the tables, grouped by `car_make`, and finally sorted by average income descending.

```sql
Sort  (cost=838.61..838.77 rows=65 width=55) (actual time=9.784..9.788 rows=62 loops=1)
  Sort Key: (round(avg(i.annual_income), 0)) DESC
  Sort Method: quicksort  Memory: 29kB
  ->  HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=9.631..9.654 rows=62 loops=1)
        Group Key: dl.car_make
        Batches: 1  Memory Usage: 32kB
        ->  Hash Join  (cost=531.22..741.79 rows=7511 width=11) (actual time=5.823..8.592 rows=5647 loops=1)
              Hash Cond: (p.ssn = i.ssn)
              ->  Hash Join  (cost=328.16..519.00 rows=7511 width=11) (actual time=2.552..4.303 rows=7511 loops=1)
                    Hash Cond: (p.license_id = dl.id)
                    ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=8) (actual time=0.010..0.350 rows=7511 loops=1)
                    ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=2.480..2.480 rows=10007 loops=1)
                          Buckets: 16384  Batches: 1  Memory Usage: 567kB
                          ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.004..1.204 rows=10007 loops=1)
              ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=3.222..3.222 rows=7514 loops=1)
                    Buckets: 8192  Batches: 1  Memory Usage: 358kB
                    ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.049..2.044 rows=7514 loops=1)
Planning Time: 2.290 ms
Execution Time: 10.161 ms
```
