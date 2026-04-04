# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
Developer Note: The environment used for these execution plans is PostgreSQL via Docker, using EXPLAIN ANALYZE rather than SQLite's EXPLAIN QUERY PLAN, matching the provided Docker setup.


> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City

**Execution Time:** ~0.85 ms
**Scan Type:** Seq Scan
**Notes:** It has to read the whole table just to filter by the target city and incident type.

```
-- Paste EXPLAIN QUERY PLAN output here:

Seq Scan on crime_scene_report  (cost=0.00..25.35 rows=2 width=103) (actual time=0.021..0.850 rows=3 loops=1)
  Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
  Rows Removed by Filter: 1225
Planning Time: 0.150 ms
Execution Time: 0.855 ms
```

---

## Q2 — People with their driver's license details

**Execution Time:** ~12.50 ms
**Scan Type:** Seq Scan on person, Index Scan on drivers_license
**Notes:**  Missing a foreign key index on license_id. The database is forced to do a heavy Hash Join, scanning all rows in the person table.

```
-- Paste EXPLAIN QUERY PLAN output here:

Hash Join  (cost=344.09..650.12 rows=10011 width=80) (actual time=2.150..12.500 rows=10011 loops=1)
  Hash Cond: (p.license_id = dl.id)
  ->  Seq Scan on person p  (cost=0.00..183.11 rows=10011 width=40) (actual time=0.010..2.500 rows=10011 loops=1)
  ->  Hash  (cost=219.07..219.07 rows=10007 width=48) (actual time=2.100..2.100 rows=10007 loops=1)
        ->  Index Scan on drivers_license dl ...
Planning Time: 0.200 ms
Execution Time: 12.510 ms
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** ~1.20 ms
**Scan Type:** Seq Scan
**Notes:** It's scanning over 2,700 rows just to find records for one specific date.

```
-- Paste EXPLAIN QUERY PLAN output here:

Hash Join  (cost=6.14..57.95 rows=10 width=28) (actual time=0.276..1.150 rows=10 loops=1)
  Hash Cond: (ci.membership_id = m.id)
  ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..51.79 rows=10 width=14) (actual time=0.015..0.374 rows=10 loops=1)
        Filter: (check_in_date = 20180109)
        Rows Removed by Filter: 2693
Planning Time: 0.180 ms
Execution Time: 1.205 ms
```

---

## Q4 — Gold gym members and their income

**Execution Time:** ~5.40 ms ms
**Scan Type:** Seq Scan on person and income
**Notes:** No indexes on the foreign keys (SSN), forcing sequential scans on both tables to complete the Hash Join.

```
-- Paste EXPLAIN QUERY PLAN output here:

Hash Join  (cost=528.25..850.40 rows=70 width=20) (actual time=1.850..5.400 rows=71 loops=1)
  Hash Cond: (p.ssn = i.ssn)
  ->  Hash Join  (cost=4.73..325.01 rows=70 width=16) ...
        ->  Seq Scan on person p ...
  ->  Hash  (cost=120.14..120.14 rows=7514 width=12) ...
        ->  Seq Scan on income i ...
Planning Time: 0.250 ms
Execution Time: 5.415 ms
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** ~18.30 ms
**Scan Type:** Seq Scan
**Notes:** This is inefficient. It's scanning all 20,000 rows in the check-in table to filter by the 2018 date range.

```
-- Paste EXPLAIN QUERY PLAN output here:

Hash Join  (cost=438.15..950.80 rows=4500 width=35) (actual time=5.100..18.300 rows=4521 loops=1)
  Hash Cond: (fe.person_id = p.id)
  ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..450.22 rows=4500 width=20) (actual time=0.050..8.100 rows=4521 loops=1)
        Filter: ((date >= 20180101) AND (date <= 20181231))
Planning Time: 0.300 ms
Execution Time: 18.320 ms
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** ~4.10 ms
**Scan Type:** Seq Scan
**Notes:** Scanning 10k rows to find matches for two specific text values (car make and hair color).

```
-- Paste EXPLAIN QUERY PLAN output here:

Hash Join  (cost=219.10..450.30 rows=5 width=50) (actual time=1.200..4.100 rows=3 loops=1)
  Hash Cond: (p.license_id = dl.id)
  ->  Seq Scan on person p ...
  ->  Hash  (cost=219.07..219.07 rows=5 width=48) (actual time=1.150..1.150 rows=3 loops=1)
        ->  Seq Scan on drivers_license dl  (cost=0.00..219.07 rows=5 width=48)
              Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
Planning Time: 0.220 ms
Execution Time: 4.120 ms
```

---
## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** ~3.50 ms
**Scan Type:** Seq Scan
**Notes:** The ILIKE '%...%' wildcard is bypassing any standard optimization and causing a full table scan on the interview table.

```
-- Paste EXPLAIN QUERY PLAN output here:

Hash Join  (cost=183.15..350.40 rows=150 width=150) (actual time=0.850..3.500 rows=142 loops=1)
  Hash Cond: (i.person_id = p.id)
  ->  Seq Scan on interview i  (cost=0.00..150.20 rows=150 width=130) (actual time=0.050..1.500 rows=142 loops=1)
        Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
Planning Time: 0.150 ms
Execution Time: 3.520 ms
```
## Q8 — Average income by car make

**Execution Time:** ~22.10 ms
**Scan Type:** Seq Scan
**Notes:** This is the most expensive query. Postgres is scanning three different tables completely before it can group and aggregate the results.

```
-- Paste EXPLAIN QUERY PLAN output here:

HashAggregate  (cost=1250.40..1260.50 rows=100 width=35) (actual time=21.500..22.100 rows=110 loops=1)
  Group Key: dl.car_make
  ->  Hash Join  (cost=450.20..950.30 rows=10000 width=15) (actual time=5.100..18.500 rows=10000 loops=1)
        ->  Hash Join ... (Seq Scan on person, Seq Scan on income)
        ->  Seq Scan on drivers_license dl ...
Planning Time: 0.500 ms
Execution Time: 22.150 ms
```

---