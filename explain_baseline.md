# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.302 ms
**Scan Type:**  Seq Scan (Full table scan)
**Notes:** Rows Removed by Filter: 1225 
 Sort Method: quicksort  Memory: 25kB

```
-- Paste EXPLAIN QUERY PLAN output here
Sort  (cost=34.43..34.44 rows=1 width=53) (actual time=0.258..0.259 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=53) (actual time=0.016..0.203 rows=3 loops=1)
         Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
         Rows Removed by Filter: 1225
 Planning Time: 0.920 ms
 Execution Time: 0.302 ms
(8 rows)
```

---

## Q2 — People with their driver's license details

**Execution Time:** 16.550 ms
**Scan Type:**  Seq Scan ondrivers_license 
**Notes:**  uckets: 16384  Batches: 1  Memory Usage: 793kB
use a hash join person.license_id = drivers_license.id
Tables are medium-sized (~7.5k and 10k rows), so Seq Scan is fine for now, but would be slow on larger tables
Potential optimization: add indexes on person.license_id or drivers_license.id if not already present


```
-- Paste EXPLAIN QUERY PLAN output here
 Sort  (cost=1002.51..1021.29 rows=7511 width=60) (actual time=15.975..16.240 rows=7511 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 997kB
   ->  Hash Join  (cost=328.16..519.00 rows=7511 width=60) (actual time=4.867..8.114 rows=7511 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=36) (actual time=0.006..0.656 rows=7511 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=4.759..4.760 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.006..2.176 rows=10007 loops=1)    
 Planning Time: 0.963 ms
 Execution Time: 16.550 ms
(11 rows)
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:**  0.117  ms
**Scan Type:**  Seq Scan on get_fit_now_member 
**Notes:** Filter: (check_in_date = 20180109)
   Sort Method: quicksort  Memory: 25kB

```
-- Paste EXPLAIN QUERY PLAN output here
 Sort  (cost=0.02..0.03 rows=1 width=72) (actual time=0.048..0.049 rows=0 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.00..0.01 rows=1 width=72) (actual time=0.005..0.005 rows=0 loops=1)
         Join Filter: (m.id = ci.membership_id)
         ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=96) (actual time=0.004..0.004 rows=0 loops=1)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..0.00 rows=1 width=40) (never executed)
               Filter: (check_in_date = 20180109)
 Planning Time: 0.471 ms
 Execution Time: 0.117 ms
(10 rows)
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 0.089 ms
**Scan Type:** Seq Scan on get_fit_now_member to filter membership_status = 'gold'
Index Scan on person (person_pkey) and income (income_pkey), though in this run they were never executed because the get_fit_now_member filter returned 0 rows

**Notes:** Sort Method: quicksort  Memory: 25kB
Nested Loop Join is used to connect get_fit_now_member → person → income
 Index Scan using income_pkey on income i
Index Scan using income_pkey on income i
```
-- Paste EXPLAIN QUERY PLAN output here
 Sort  (cost=8.64..8.65 rows=1 width=68) (actual time=0.024..0.026 rows=0 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.56..8.63 rows=1 width=68) (actual time=0.004..0.005 rows=0 loops=1)
         ->  Nested Loop  (cost=0.28..8.30 rows=1 width=68) (actual time=0.004..0.004 rows=0 loops=1)
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=68) (actual time=0.003..0.004 rows=0 loops=1)
                     Filter: (membership_status = 'gold'::text)
               ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=8) (never executed)
                     Index Cond: (id = m.person_id)
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.33 rows=1 width=8) (never executed)
               Index Cond: (ssn = p.ssn)
 Planning Time: 0.712 ms
 Execution Time: 0.089 ms
(13 rows)
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 0.081 ms
**Scan Type:** Seq Scan on facebook_event_checkin fe 
Index Scan using person_pkey on person p 

**Notes:** Sort Method: quicksort  Memory: 25kB
         ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
```   ->  Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.006..0.006 rows=0 loops=1)

-- Paste EXPLAIN QUERY PLAN output here

Sort  (cost=8.31..8.32 rows=1 width=50) (actual time=0.025..0.026 rows=0 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.006..0.006 rows=0 loops=1)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..0.00 rows=1 width=40) (actual time=0.005..0.006 rows=0 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
         ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
               Index Cond: (id = fe.person_id)
 Planning Time: 0.384 ms
 Execution Time: 0.081 ms
(10 rows)
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 2.873 ms
**Scan Type:** Seq Scan on person (7,511 rows)
Seq Scan on drivers_license (10,007 rows) with filter (hair_color = 'red' AND car_make = 'Tesla'), removed 10,003 rows → slow full scan

**Notes:** Sort Method: quicksort  Memory: 25kB
Hash Join used to link person.license_id = drivers_license.id
Small result set (3 rows) but most of drivers_license was scanned → target for optimization

```
-- Paste EXPLAIN QUERY PLAN output here
 Sort  (cost=443.98..443.98 rows=2 width=40) (actual time=2.841..2.850 rows=3 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..443.97 rows=2 width=40) (actual time=1.550..2.834 rows=3 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=18) (actual time=0.005..0.676 rows=7511 loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=0.694..0.694 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.113..0.689 rows=4 loops=1)
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 0.353 ms
 Execution Time: 2.873 ms
(13 rows)
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:**0.032 ms
**Scan Type:**  Seq Scan on interview i
Index Scan using person_pkey on person p  (1)
**Notes:**
 Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.005..0.006 rows=0 loops=1)
```
-- Paste EXPLAIN QUERY PLAN output here
Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.005..0.006 rows=0 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..0.00 rows=1 width=36) (actual time=0.005..0.005 rows=0 loops=1)
         Filter: ((transcript ~~ '%gym%'::text) OR (transcript ~~ '%murder%'::text))
   ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
         Index Cond: (id = i.person_id)
 Planning Time: 0.236 ms
 Execution Time: 0.032 ms
(7 rows)

```

---

## Q8 — Average income by car make

**Execution Time:**  9.171 ms
**Scan Type:** Hash Join used to link person → drivers_license → income
Seq Scan on person (7,511 rows), drivers_license (10,007 rows), and income (7,514 rows)
**Notes:** Memory used for hash joins: drivers_license 567 kB, income 358 kB
Index on person.ssn and income.ssn to speed up joins
Aggregation done with HashAggregate on dl.car_make (62 groups returned)

```
-- Paste EXPLAIN QUERY PLAN output here
 Sort  (cost=838.61..838.77 rows=65 width=55) (actual time=8.979..8.983 rows=62 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=8.809..8.827 rows=62 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..741.79 rows=7511 width=11) (actual time=5.630..7.927 rows=5647 loops=1)
               Hash Cond: (p.ssn = i.ssn)
               ->  Hash Join  (cost=328.16..519.00 rows=7511 width=11) (actual time=2.364..3.852 rows=7511 loops=1)
                     Hash Cond: (p.license_id = dl.id)
                     ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=8) (actual time=0.004..0.350 rows=7511 loops=1)
                     ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=2.281..2.281 rows=10007 loops=1)
                           Buckets: 16384  Batches: 1  Memory Usage: 567kB
                           ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.003..1.043 rows=10007 loops=1)
               ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=3.211..3.211 rows=7514 loops=1)
                     Buckets: 8192  Batches: 1  Memory Usage: 358kB
                     ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.033..2.200 rows=7514 loops=1)
 Planning Time: 1.070 ms
 Execution Time: 9.171 ms
(19 rows)

```
