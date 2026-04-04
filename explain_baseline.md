# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City


**Execution Time:** 0.155 ms  
**Scan Type:** Seq Scan on crime_scene_report  
**Join Method:** None  
**Notes:** Full table scan on crime_scene_report. PostgreSQL scanned all rows and filtered most of them. A Sort operation was performed on date DESC using quicksort, indicating no supporting index for filtering or sorting.
 
```
Sort (cost=34.43..34.44 rows=1 width=53) (actual time=0.137..0.138 rows=3 loops=1)
Sort Key: date DESC
Sort Method: quicksort Memory: 25kB
-> Seq Scan on crime_scene_report (cost=0.00..34.42 rows=1 width=53) (actual time=0.008..0.122 rows=3 loops=1)
Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
Rows Removed by Filter: 1225
Planning Time: 0.346 ms
Execution Time: 0.155 ms

## Q2 — People with their driver's license details

**Execution Time:** 13.467 ms  
**Scan Type:** Seq Scan on person and Seq Scan on drivers_license  
**Join Method:** Hash Join  
**Notes:** PostgreSQL performed sequential scans on both `person` and `drivers_license`, then used a Hash Join on `p.license_id = dl.id`. Because the query returns many rows and has no filtering, the planner preferred full scans over index lookups. A separate Sort operation was also required for `ORDER BY p.name`.


```
Sort (cost=1002.51..1021.29 rows=7511 width=60) (actual time=12.995..13.215 rows=7511 loops=1)
Sort Key: p.name
Sort Method: quicksort Memory: 997kB
-> Hash Join (cost=328.16..519.00 rows=7511 width=60) (actual time=2.279..3.633 rows=7511 loops=1)
Hash Cond: (p.license_id = dl.id)
-> Seq Scan on person p (cost=0.00..171.11 rows=7511 width=36) (actual time=0.004..0.297 rows=7511 loops=1)
-> Hash (cost=203.07..203.07 rows=10007 width=32) (actual time=2.207..2.208 rows=10007 loops=1)
Buckets: 16384 Batches: 1 Memory Usage: 793kB
-> Seq Scan on drivers_license dl (cost=0.00..203.07 rows=10007 width=32) (actual time=0.008..0.819 rows=10007 loops=1)
Planning Time: 3.429 ms
Execution Time: 13.467 ms

```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.031 ms  
**Scan Type:** Seq Scan on get_fit_now_member and Seq Scan on get_fit_now_check_in  
**Join Method:** Nested Loop  
**Notes:** PostgreSQL performed a sequential scan on `get_fit_now_member`, but since no matching rows were found, the second scan on `get_fit_now_check_in` was never executed. The planner still shows a filter on `check_in_date`, but no rows satisfied the condition, resulting in zero output rows.


```
Sort (cost=0.02..0.03 rows=1 width=72) (actual time=0.012..0.014 rows=0 loops=1)
Sort Key: ci.check_in_time
Sort Method: quicksort Memory: 25kB
-> Nested Loop (cost=0.00..0.01 rows=1 width=72) (actual time=0.002..0.003 rows=0 loops=1)
Join Filter: (m.id = ci.membership_id)
-> Seq Scan on get_fit_now_member m (cost=0.00..0.00 rows=1 width=96) (actual time=0.002..0.002 rows=0 loops=1)
-> Seq Scan on get_fit_now_check_in ci (cost=0.00..0.00 rows=1 width=40) (never executed)
Filter: (check_in_date = 20180109)
Planning Time: 0.313 ms
Execution Time: 0.031 ms
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 0.028 ms  
**Scan Type:** Seq Scan on get_fit_now_member + Index Scan on person + Index Scan on income  
**Join Method:** Nested Loop  
**Notes:** PostgreSQL performs a sequential scan on `get_fit_now_member` to filter rows where membership_status = 'gold'. Since no matching rows were found, the subsequent index scans on `person` and `income` were never executed. The plan still shows index usage on primary keys for joins. A Sort operation was included for ordering by annual income.


```
Sort (cost=8.64..8.65 rows=1 width=68) (actual time=0.007..0.008 rows=0 loops=1)
Sort Key: i.annual_income DESC
Sort Method: quicksort Memory: 25kB
-> Nested Loop (cost=0.56..8.63 rows=1 width=68) (actual time=0.003..0.003 rows=0 loops=1)
-> Nested Loop (cost=0.28..8.30 rows=1 width=68) (actual time=0.003..0.003 rows=0 loops=1)
-> Seq Scan on get_fit_now_member m (cost=0.00..0.00 rows=1 width=68) (actual time=0.002..0.003 rows=0 loops=1)
Filter: (membership_status = 'gold'::text)
-> Index Scan using person_pkey on person p (cost=0.28..8.30 rows=1 width=8) (never executed)
Index Cond: (id = m.person_id)
-> Index Scan using income_pkey on income i (cost=0.28..0.33 rows=1 width=8) (never executed)
Index Cond: (ssn = p.ssn)
Planning Time: 0.315 ms
Execution Time: 0.028 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 0.021 ms  
**Scan Type:** Seq Scan on facebook_event_checkin + Index Scan on person  
**Join Method:** Nested Loop  
**Notes:** PostgreSQL performs a sequential scan on `facebook_event_checkin` to filter rows within the specified date range. Since no rows matched the condition, the index scan on `person` was never executed. A Sort operation is included for ordering by date.


```
 Sort  (cost=8.31..8.32 rows=1 width=50) (actual time=0.007..0.007 rows=0 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.003..0.004 rows=0 loops=1)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..0.00 rows=1 width=40) (actual time=0.003..0.00
3 rows=0 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
         ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
               Index Cond: (id = fe.person_id)
 Planning Time: 0.116 ms
 Execution Time: 0.021 ms

```

---

## Q6 — Red-haired Tesla drivers

## Q6 — Red-haired Tesla drivers

**Execution Time:** 1.857 ms  
**Scan Type:** Seq Scan on person and Seq Scan on drivers_license  
**Join Method:** Hash Join  
**Notes:** PostgreSQL performs sequential scans on both `person` and `drivers_license`. The filter on `drivers_license` (hair_color and car_make) is applied during the scan, removing most rows. A Hash Join is then used to join the filtered results with the `person` table. A Sort operation is also performed for ordering by `p.name`.

```
Sort  (cost=443.98..443.98 rows=2 width=40) (actual time=1.834..1.836 rows=3 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..443.97 rows=2 width=40) (actual time=1.380..1.825 rows=3 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=18) (actual time=0.004..0.376 rows=7511
loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=0.956..0.957 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.124..0.9
52 rows=4 loops=1)
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 0.213 ms
 Execution Time: 1.857 ms

```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 0.031 ms  
**Scan Type:** Seq Scan on interview + Index Scan on person  
**Join Method:** Nested Loop  
**Notes:** PostgreSQL performs a sequential scan on `interview` because the `ILIKE '%...%'` pattern requires scanning the text column and cannot use a normal B-tree index efficiently. No rows matched the condition, so the index scan on `person` was never executed.



```
Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.005..0.006 rows=0 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..0.00 rows=1 width=36) (actual time=0.005..0.005 rows=0 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
   ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
         Index Cond: (id = i.person_id)
 Planning Time: 6.010 ms
 Execution Time: 0.031 ms

```

---

## Q8 — Average income by car make

**Execution Time:** ___ ms  
**Scan Type:** Seq Scan on person, Seq Scan on drivers_license, and Seq Scan on income  
**Join Method:** Hash Join  
**Notes:** PostgreSQL performs sequential scans on all three tables, then uses hash joins to combine them. After joining, it applies a HashAggregate to calculate the grouped income statistics by `car_make`, followed by a Sort for `ORDER BY avg_income DESC`. This query processes many rows, so full scans are expected before indexing.

```
 Sort  (cost=838.61..838.77 rows=65 width=55) (actual time=5.130..5.134 rows=62 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=5.083..5.100 rows=62 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..741.79 rows=7511 width=11) (actual time=2.513..4.485 rows=5647 loops=1)
               Hash Cond: (p.ssn = i.ssn)
               ->  Hash Join  (cost=328.16..519.00 rows=7511 width=11) (actual time=1.566..2.827 rows=7511 loo
ps=1)
                     Hash Cond: (p.license_id = dl.id)
                     ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=8) (actual time=0.002..0.278
 rows=7511 loops=1)
                     ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=1.516..1.516 rows=10007
loops=1)
                           Buckets: 16384  Batches: 1  Memory Usage: 567kB
                           ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual
 time=0.003..0.646 rows=10007 loops=1)
               ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=0.933..0.933 rows=7514 loops=1)

```
