# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City

**Execution Time:** __0.462_ ms
**Scan Type:** __Seq Scan_
**Join method**:N/A
**Notes:** _ The query performs a full table scan on crime_scene_report, scanning 1,228 rows to return only 3 matching rows. This indicates inefficient filtering due to the absence of an index on the filtered columns (city and type).__

```
-- Paste EXPLAIN QUERY PLAN output here
```

---```sql
Sort  (cost=34.43..34.44 rows=1 width=53) (actual time=0.433..0.436 rows=3 loops=1)
  Sort Key: date DESC
  Sort Method: quicksort  Memory: 25kB
  ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=53) (actual time=0.013..0.411 rows=3 loops=1)
        Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
        Rows Removed by Filter: 1225
Planning Time: 0.550 ms
Execution Time: 0.462 ms

## Q2 — People with their driver's license details

**Execution Time:** __34.129_ ms
**Scan Type:** __Seq Scan on `person`, Seq Scan on `drivers_license`_
**Notes:** __The query performs sequential scans on both `person` and `drivers_license` before joining them with a hash join. Because the query returns a large portion of rows and has no filtering condition, sequential scans are reasonable here and may be more efficient than index lookups._

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

**Execution Time:** __1.630_ ms
**Scan Type:** _Seq Scan__
**Notes:** __The query returned no rows, so the execution plan is not representative of actual performance. The check_in_date filter did not match any records, and the join was not fully executed. Therefore, it is difficult to evaluate whether indexing would improve performance in this case._

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

**Execution Time:** 0.075 ms  
**Scan Type:** Seq Scan on `get_fit_now_member`
**Notes:** _The query returned no rows, so the execution plan is not representative of actual performance. PostgreSQL performed a sequential scan to filter `membership_status = 'gold'`, but no matching rows were found. As a result, the joins to `person` and `income` were not executed.__

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

**Execution Time:** __ 0.023_ ms
**Scan Type:** _Seq Scan on facebook_event_checkin __
**Notes:** __The query returned no rows for the specified date range. PostgreSQL performed a sequential scan to evaluate the date filter, but no records matched. Therefore, the join to `person` was not executed, and the plan does not reflect real workload performance._

```
-- Paste EXPLAIN QUERY PLAN output here
```sql
Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.005..0.005 rows=0 loops=1)
  ->  Seq Scan on facebook_event_checkin fe
        Filter: ((date >= 20180101) AND (date <= 20181231))
  ->  Index Scan using person_pkey on person p (never executed)
Planning Time: 2.992 ms
Execution Time: 0.023 ms

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** _5.013 ms__ ms
**Scan Type:** _Seq Scan on `drivers_license`, Index Scan on `person`  __
**Notes:** _The query performs a sequential scan on `drivers_license`, scanning over 10,000 rows and filtering out 10,003 of them to return only a few matches. This indicates inefficient filtering and makes the query a strong candidate for indexing on `(hair_color, car_make)`. The join to `person` is efficient due to the index on `person(license_id)`.
__

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

**Execution Time:** __ 0.021_ ms
**Scan Type:** _Seq Scan on `interview`__
**Notes:** _The query returned no rows, and PostgreSQL performed a sequential scan on `interview`. The condition uses `ILIKE '%...%'`, which prevents the use of standard B-tree indexes. Even if data were present, this query would likely require a full table scan unless more advanced indexing techniques are used.__

```
-- Paste EXPLAIN QUERY PLAN output here
```sql
Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.004..0.005 rows=0 loops=1)
  ->  Seq Scan on interview i
        Filter: ((transcript ~~* '%gym%') OR (transcript ~~* '%murder%'))
  ->  Index Scan using person_pkey on person p (never executed)
Planning Time: 0.280 ms
Execution Time: 0.021 ms

---

## Q8 — Average income by car make

**Execution Time:** _11.720__ ms
**Scan Type:** _Seq Scan on `person`, `drivers_license`, and `income`__
**Notes:** _The query scans large portions of all three tables and uses hash joins followed by aggregation. Because there is no filtering condition, PostgreSQL must process a significant amount of data. In such cases, sequential scans and hash joins are appropriate and more efficient than index lookups.
__

```
-- Paste EXPLAIN QUERY PLAN output here
```sql
HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=10.500..10.551 rows=62 loops=1)
  Group Key: dl.car_make
  ->  Hash Join
        ->  Hash Join
              ->  Seq Scan on person p
              ->  Seq Scan on drivers_license dl
        ->  Seq Scan on income i
Planning Time: 8.663 ms
Execution Time: 11.720 ms
