# Indexed Execution Plans

## Q1 — All murders in SQL City

```sql
EXPLAIN ANALYZE
SELECT date, description
FROM crime_scene_report
WHERE city = 'SQL City'
  AND type = 'murder'
ORDER BY date DESC;
```

**Execution Time:** 0.076 ms  
**Scan Type:** Index Scan on `crime_scene_report` using `idx_crime_city_type`  
**Join Method:** None  
**Notes:** The query improved after adding the composite index on `(city, type)`. PostgreSQL used an index scan instead of a sequential scan, which reduced execution time and avoided scanning the full table.

## Q2 — People with their driver’s license details

```sql
EXPLAIN ANALYZE
SELECT p.name, p.address_number, p.address_street_name,
       dl.age, dl.eye_color, dl.hair_color, dl.car_make, dl.car_model
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
ORDER BY p.name;
```

**Execution Time:** 15.905 ms  
**Scan Type:** Seq Scan on `person`, Seq Scan on `drivers_license`  
**Join Method:** Hash Join  
**Notes:** This query showed no meaningful improvement. PostgreSQL still chose sequential scans and a hash join, likely because the query reads almost all rows from both tables, making full scans cheaper than index lookups.

## Q3 — Gym members who checked in on January 9, 2018

```sql
EXPLAIN ANALYZE
SELECT m.name, m.membership_status, ci.check_in_time, ci.check_out_time
FROM get_fit_now_member m
JOIN get_fit_now_check_in ci ON m.id = ci.membership_id
WHERE ci.check_in_date = 20180109
ORDER BY ci.check_in_time;
```

**Execution Time:** 0.110 ms  
**Scan Type:** Bitmap Heap Scan on `get_fit_now_check_in`, Bitmap Index Scan on `idx_checkin_date`, Seq Scan on `get_fit_now_member`  
**Join Method:** Hash Join  
**Notes:** This query improved after indexing `check_in_date`. PostgreSQL used the new index to find matching rows efficiently, replacing the earlier sequential scan on `get_fit_now_check_in`.

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

**Execution Time:** 1.625 ms  
**Scan Type:** Seq Scan on `person`, Seq Scan on `get_fit_now_member`, Index Scan on `income` using `income_pkey`  
**Join Method:** Hash Join, then Nested Loop  
**Notes:** This query did not improve materially. PostgreSQL already used an index on `income(ssn)` before indexing, and the additional indexes did not significantly change the plan.

## Q5 — People who attended Facebook events in 2018

```sql
EXPLAIN ANALYZE
SELECT p.name, fe.event_name, fe.date
FROM person p
JOIN facebook_event_checkin fe ON p.id = fe.person_id
WHERE fe.date BETWEEN 20180101 AND 20181231
ORDER BY fe.date DESC;
```

**Execution Time:** 4.428 ms  
**Scan Type:** Bitmap Heap Scan on `facebook_event_checkin`, Bitmap Index Scan on `idx_facebook_date`, Seq Scan on `person`  
**Join Method:** Hash Join  
**Notes:** This query improved after indexing `facebook_event_checkin(date)`. PostgreSQL used the date index to locate matching rows in the requested range instead of scanning the full event table.

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

**Execution Time:** 0.160 ms  
**Scan Type:** Index-based access on `drivers_license` using `idx_license_hair_car`, Index Scan on `person` using `idx_person_license`  
**Join Method:** Nested Loop  
**Notes:** This query improved dramatically. PostgreSQL used the composite index on `(hair_color, car_make)` to find the matching licenses and then used the join index on `person(license_id)` to fetch the related people efficiently.

## Q7 — Interview transcripts mentioning the gym or murder

```sql
EXPLAIN ANALYZE
SELECT p.name, i.transcript
FROM interview i
JOIN person p ON i.person_id = p.id
WHERE i.transcript ILIKE '%gym%'
   OR i.transcript ILIKE '%murder%';
```

**Execution Time:** 5.626 ms  
**Scan Type:** Seq Scan on `interview`, Index Scan on `person` using `person_pkey`  
**Join Method:** Nested Loop  
**Notes:** This query did not improve. PostgreSQL still used a sequential scan on `interview` because the condition uses `ILIKE '%...%'`, which does not benefit from a regular B-tree index.

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

**Execution Time:** 7.598 ms  
**Scan Type:** Seq Scan on `person`, Seq Scan on `income`, Seq Scan on `drivers_license`  
**Join Method:** Hash Join, Hash Join, HashAggregate  
**Notes:** This query did not improve and became slightly slower. Since it reads and aggregates a large portion of all three tables, PostgreSQL still preferred sequential scans and hash operations over index-based access.