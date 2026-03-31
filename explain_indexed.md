# explain_indexed.md — After Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the output below.
> Also run `\timing on` in psql to capture execution time.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`
> Then type: `\timing on`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.480 ms  
**Scan Type:** Index Scan  
**Notes:** PostgreSQL used `idx_crime_city_type` to find matching rows by `city` and `type`, then sorted the results by `date DESC`. This is an improvement over the baseline `Seq Scan`.

```sql
Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.300..0.301 rows=3 loops=1)
  Sort Key: date DESC
  Sort Method: quicksort  Memory: 25kB
  ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=0.175..0.183 rows=3 loops=1)
        Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
Planning Time: 1.320 ms
Execution Time: 0.480 ms
```
## Q2 — People with their drivers license details

**Execution Time**: 13.723 ms
Scan Type: Seq Scan + Hash Join
Notes: PostgreSQL still used sequential scans on both person and drivers_license, followed by a hash join on license_id = id, and then sorted by p.name. The join plan did not change, but execution time improved compared with the baseline.
```sql
Sort  (cost=1002.51..1021.29 rows=7511 width=60) (actual time=13.174..13.446 rows=7511 loops=1)
  Sort Key: p.name
  Sort Method: quicksort  Memory: 997kB
  ->  Hash Join  (cost=328.16..519.00 rows=7511 width=60) (actual time=2.852..4.794 rows=7511 loops=1)
        Hash Cond: (p.license_id = dl.id)
        ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=36) (actual time=0.006..0.376 rows=7511 loops=1)
        ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=2.770..2.770 rows=10007 loops=1)
              Buckets: 16384  Batches: 1  Memory Usage: 793kB
              ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.005..1.203 rows=10007 loops=1)
Planning Time: 0.803 ms
Execution Time: 13.723 ms
```
## Q3 — Gym members who checked in on January 9, 2018

Execution Time: 0.109 ms
Scan Type: Seq Scan + Nested Loop
Notes: PostgreSQL still used a sequential scan on get_fit_now_member, and the scan on get_fit_now_check_in was never executed because the query returned 0 rows. No visible improvement appeared in this dataset.
```sql
Sort  (cost=0.02..0.03 rows=1 width=72) (actual time=0.009..0.010 rows=0 loops=1)
  Sort Key: ci.check_in_time
  Sort Method: quicksort  Memory: 25kB
  ->  Nested Loop  (cost=0.00..0.01 rows=1 width=72) (actual time=0.004..0.004 rows=0 loops=1)
        Join Filter: (m.id = ci.membership_id)
        ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=96) (actual time=0.003..0.003 rows=0 loops=1)
        ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..0.00 rows=1 width=40) (never executed)
              Filter: (check_in_date = 20180109)
Planning Time: 1.084 ms
Execution Time: 0.109 ms
```
## Q4 — Gold gym members and their income

Execution Time: 0.109 ms
Scan Type: Seq Scan + Index Scan + Nested Loop
Notes: PostgreSQL still used a sequential scan on get_fit_now_member for the membership_status = 'gold' filter. The query returned 0 rows, so later steps were not fully used. The income join now uses idx_income_ssn.
```sql
Sort  (cost=8.64..8.65 rows=1 width=68) (actual time=0.018..0.019 rows=0 loops=1)
  Sort Key: i.annual_income DESC
  Sort Method: quicksort  Memory: 25kB
  ->  Nested Loop  (cost=0.56..8.63 rows=1 width=68) (actual time=0.004..0.005 rows=0 loops=1)
        ->  Nested Loop  (cost=0.28..8.30 rows=1 width=68) (actual time=0.004..0.005 rows=0 loops=1)
              ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=68) (actual time=0.004..0.004 rows=0 loops=1)
                    Filter: (membership_status = 'gold'::text)
              ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=8) (never executed)
                    Index Cond: (id = m.person_id)
        ->  Index Scan using idx_income_ssn on income i  (cost=0.28..0.33 rows=1 width=8) (never executed)
              Index Cond: (ssn = p.ssn)
Planning Time: 2.382 ms
Execution Time: 0.109 ms
```
## Q5 — People who attended Facebook events in 2018

Execution Time: 0.037 ms
Scan Type: Seq Scan + Index Scan + Nested Loop
Notes: PostgreSQL still used a sequential scan on facebook_event_checkin for the date filter. No rows matched, so the join to person was never executed. Execution time improved, but the access method did not change.

```sql 
Sort  (cost=8.31..8.32 rows=1 width=50) (actual time=0.012..0.013 rows=0 loops=1)
  Sort Key: fe.date DESC
  Sort Method: quicksort  Memory: 25kB
  ->  Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.007..0.008 rows=0 loops=1)
        ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..0.00 rows=1 width=40) (actual time=0.006..0.006 rows=0 loops=1)
              Filter: ((date >= 20180101) AND (date <= 20181231))
        ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
              Index Cond: (id = fe.person_id)
Planning Time: 0.931 ms
Execution Time: 0.037 ms
```
## Q6 — Red-haired Tesla drivers

Execution Time: 5.476 ms
Scan Type: Bitmap Heap Scan + Bitmap Index Scan + Index Scan + Nested Loop
Notes: PostgreSQL used the new composite index idx_dl_hair_make to filter drivers_license, then used idx_person_license to join to person. The access pattern improved from full scans to indexed access, even though execution time increased in this small dataset.
```sql
Sort  (cost=28.13..28.13 rows=2 width=40) (actual time=5.330..5.331 rows=3 loops=1)
  Sort Key: p.name
  Sort Method: quicksort  Memory: 25kB
  ->  Nested Loop  (cost=4.59..28.12 rows=2 width=40) (actual time=4.934..5.246 rows=3 loops=1)
        ->  Bitmap Heap Scan on drivers_license dl  (cost=4.31..11.50 rows=2 width=30) (actual time=4.824..4.857 rows=4 loops=1)
              Recheck Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
              Heap Blocks: exact=4
              ->  Bitmap Index Scan on idx_dl_hair_make  (cost=0.00..4.30 rows=2 width=0) (actual time=4.763..4.763 rows=4 loops=1)
                    Index Cond: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
        ->  Index Scan using idx_person_license on person p  (cost=0.28..8.30 rows=1 width=18) (actual time=0.095..0.095 rows=1 loops=4)
              Index Cond: (license_id = dl.id)
Planning Time: 1.538 ms
Execution Time: 5.476 ms

```

## Q7 — Interview transcripts mentioning the gym or murder

Execution Time: 0.023 ms
Scan Type: Seq Scan + Index Scan + Nested Loop
Notes: PostgreSQL still used a sequential scan on interview because the query uses LIKE '%gym%' and LIKE '%murder%', which are not helped much by normal B-tree indexes. The join to person was not executed because no rows matched.
```sql
Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.006..0.006 rows=0 loops=1)
  ->  Seq Scan on interview i  (cost=0.00..0.00 rows=1 width=36) (actual time=0.005..0.005 rows=0 loops=1)
        Filter: ((transcript ~~ '%gym%'::text) OR (transcript ~~ '%murder%'::text))
  ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
        Index Cond: (id = i.person_id)
Planning Time: 0.245 ms
Execution Time: 0.023 ms
```
## Q8 — Average income by car make

Execution Time: 9.635 ms
Scan Type: Seq Scan + Hash Join + HashAggregate
Notes: PostgreSQL still used sequential scans on person, drivers_license, and income, followed by hash joins and aggregation. The plan did not materially change, although execution time improved slightly.
```sql
Sort  (cost=838.61..838.77 rows=65 width=55) (actual time=9.386..9.406 rows=62 loops=1)
  Sort Key: (round(avg(i.annual_income), 0)) DESC
  Sort Method: quicksort  Memory: 29kB
  ->  HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=9.269..9.307 rows=62 loops=1)
        Group Key: dl.car_make
        Batches: 1  Memory Usage: 32kB
        ->  Hash Join  (cost=531.22..741.79 rows=7511 width=11) (actual time=5.306..8.292 rows=5647 loops=1)
              Hash Cond: (p.ssn = i.ssn)
              ->  Hash Join  (cost=328.16..519.00 rows=7511 width=11) (actual time=3.430..5.398 rows=7511 loops=1)
                    Hash Cond: (p.license_id = dl.id)
                    ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=8) (actual time=0.003..0.407 rows=7511 loops=1)
                    ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=3.326..3.326 rows=10007 loops=1)
                          Buckets: 16384  Batches: 1  Memory Usage: 567kB
                          ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.004..1.754 rows=10007 loops=1)
              ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=1.847..1.847 rows=7514 loops=1)
                    Buckets: 8192  Batches: 1  Memory Usage: 358kB
                    ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.006..0.809 rows=7514 loops=1)
Planning Time: 0.538 ms
Execution Time: 9.635 ms
```