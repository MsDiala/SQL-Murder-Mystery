# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`

---

## Q1 — All murders in SQL City

# Baseline Execution Plans

## Q1 — All murders in SQL City

```sql
EXPLAIN ANALYZE
SELECT date, description
FROM crime_scene_report
WHERE city = 'SQL City'
  AND type = 'murder'
ORDER BY date DESC;
```
**Execution Time:** 0.114 ms  
**Scan Type:** Seq Scan on crime_scene_report  
**Join Method:** None  
**Notes:** PostgreSQL performed a sequential scan on the entire `crime_scene_report` table, then filtered rows where `city = 'SQL City'` and `type = 'murder'`. Only 3 rows matched, while 1225 rows were removed by the filter. The query also performed a sort on `date DESC`. This suggests that an index on `(city, type)` could improve filtering performance.
```

---

## Q2 — People with their driver’s license details

```sql
EXPLAIN ANALYZE
SELECT p.name, p.address_number, p.address_street_name,
       dl.age, dl.eye_color, dl.hair_color, dl.car_make, dl.car_model
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
ORDER BY p.name;
```

**Execution Time:** 15.580 ms  
**Scan Type:** Seq Scan on `person`, Seq Scan on `drivers_license`  
**Join Method:** Hash Join  
**Notes:** PostgreSQL used a hash join between `person` and `drivers_license` on `p.license_id = dl.id`. Both tables were read using sequential scans, and the final result was sorted by `p.name`. Since this query joins on `license_id`, an index on `person(license_id)` may help improve join performance.

## Q3 — Gym members who checked in on January 9, 2018

```sql
EXPLAIN ANALYZE
SELECT m.name, m.membership_status, ci.check_in_time, ci.check_out_time
FROM get_fit_now_member m
JOIN get_fit_now_check_in ci ON m.id = ci.membership_id
WHERE ci.check_in_date = 20180109
ORDER BY ci.check_in_time;
```

**Execution Time:** 0.183 ms  
**Scan Type:** Seq Scan on `get_fit_now_check_in`, Seq Scan on `get_fit_now_member`  
**Join Method:** Hash Join  
**Notes:** PostgreSQL used a hash join between `get_fit_now_check_in` and `get_fit_now_member`. The query performed a sequential scan on `get_fit_now_check_in` and filtered on `check_in_date = 20180109`, removing 2693 rows to return only 10 matches. This makes `check_in_date` a strong candidate for indexing. The final result was sorted by `ci.check_in_time`.

---

## Q4 — Gold gym members and their income

```sql
EXPLAIN ANALYZE
SELECT m.name, m.membership_status, i.annual_income
FROM get_fit_now_member m
JOIN person p ON m.person_id = p.id
JOIN income i ON p.ssn = i.ssn
WHERE m.membership_status = 'gold'
ORDER BY i.annual_income DESC;
```

**Execution Time:** 1.564 ms  
**Scan Type:** Seq Scan on `person`, Seq Scan on `get_fit_now_member`, Index Scan on `income` using `income_pkey`  
**Join Method:** Hash Join, then Nested Loop  
**Notes:** PostgreSQL first filtered `get_fit_now_member` for `membership_status = 'gold'`, then used a hash join with `person` on `m.person_id = p.id`. After that, it used an index scan on `income` through `income_pkey` for the join on `ssn`. The scan on `get_fit_now_member` is acceptable because the table is small, but the sequential scan on `person` may still be a possible optimization target.

---

## Q5 — People who attended Facebook events in 2018

```sql
EXPLAIN ANALYZE
SELECT p.name, fe.event_name, fe.date
FROM person p
JOIN facebook_event_checkin fe ON p.id = fe.person_id
WHERE fe.date BETWEEN 20180101 AND 20181231
ORDER BY fe.date DESC;
```

**Execution Time:** 4.988 ms  
**Scan Type:** Seq Scan on `facebook_event_checkin`, Seq Scan on `person`  
**Join Method:** Hash Join  
**Notes:** PostgreSQL used a hash join between `facebook_event_checkin` and `person`. The query performed a sequential scan on `facebook_event_checkin` while filtering rows for the 2018 date range, removing 14986 rows and keeping 5025. This makes `facebook_event_checkin(date)` a strong candidate for indexing. The query also sorted the final output by `fe.date DESC`.

---

## Q6 — Red-haired Tesla drivers


```sql
EXPLAIN ANALYZE
SELECT p.name, dl.hair_color, dl.car_make, dl.car_model, dl.plate_number
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
WHERE dl.hair_color = 'red'
  AND dl.car_make = 'Tesla'
ORDER BY p.name;
```

**Execution Time:** 2.395 ms  
**Scan Type:** Seq Scan on `person`, Seq Scan on `drivers_license`  
**Join Method:** Hash Join  
**Notes:** PostgreSQL used a hash join between `person` and `drivers_license`. The query performed a sequential scan on `drivers_license` while filtering for `hair_color = 'red'` and `car_make = 'Tesla'`, returning only 4 rows and removing 10003 rows. This is a strong sign that a composite index on `(hair_color, car_make)` could improve performance. The final result was sorted by `p.name`.

---

## Q7 — Interview transcripts mentioning the gym or murder

```sql
EXPLAIN ANALYZE
SELECT p.name, i.transcript
FROM interview i
JOIN person p ON i.person_id = p.id
WHERE i.transcript ILIKE '%gym%'
   OR i.transcript ILIKE '%murder%';
```

**Execution Time:** 5.497 ms  
**Scan Type:** Seq Scan on `interview`, Index Scan on `person` using `person_pkey`  
**Join Method:** Nested Loop  
**Notes:** PostgreSQL performed a sequential scan on `interview` because the filter uses `ILIKE '%...%'`, which generally cannot use a regular B-tree index efficiently. Only 4 rows matched, while 4987 were removed by the filter. The join to `person` used an index scan on `person_pkey`, which is efficient. This query may not improve much with a standard index unless a specialized text-search index is used.

---
## Q8 — Average income by car make

```sql
EXPLAIN ANALYZE
SELECT dl.car_make,
       COUNT(*) AS drivers,
       ROUND(AVG(i.annual_income), 0) AS avg_income,
       MIN(i.annual_income) AS min_income,
       MAX(i.annual_income) AS max_income
FROM drivers_license dl
JOIN person p ON dl.id = p.license_id
JOIN income i ON p.ssn = i.ssn
GROUP BY dl.car_make
ORDER BY avg_income DESC;
```

**Execution Time:** 6.588 ms  
**Scan Type:** Seq Scan on `person`, Seq Scan on `income`, Seq Scan on `drivers_license`  
**Join Method:** Hash Join, Hash Join, HashAggregate  
**Notes:** PostgreSQL performed sequential scans on all three tables, then used hash joins to combine them and a hash aggregate to compute grouped income statistics by `car_make`. Since this query reads and aggregates a large portion of the data, indexes may provide limited benefit compared with more selective filter queries. However, join-related indexes such as `person(license_id)` can still be useful for overall workload performance.

