# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.069 ms *(baseline: 0.184 ms | change: -0.115 ms)*
**Scan Type:** Index Scan
**Index Used:** idx_crime_type_city

```
    EXPLAIN ANALYZE
    SELECT *
    FROM crime_scene_report
    WHERE type = 'murder'
    AND city = 'SQL City';
```

---

## Q2 — People with their driver's license details

**Execution Time:** 18.991 ms *(baseline: 7.582 ms | change: +11.415 )*
**Scan Type:** Seq Scan
**Index Used:** None (planner chose Seq Scan)

```
    EXPLAIN ANALYZE
    SELECT p.name, p.address_number, p.address_street_name, d.age, d.car_make, d.car_model
    FROM person p
    JOIN drivers_license d
    ON p.license_id = d.id;
```

### Adding an index does not always improve performance. When a query accesses most rows in a table, PostgreSQL prefers Sequential Scan over Index Scan.
---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.925 ms *(baseline: 0.315 ms | change: +0.61 ms)*
**Scan Type:** Seq Scan
**Index Used:** None (planner chose Seq Scan)

```
    EXPLAIN ANALYZE
    SELECT m.*
    FROM get_fit_now_member m
    JOIN get_fit_now_check_in c
    ON m.id = c.membership_id
    WHERE c.check_in_date = 20180109;
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 6.729 ms *(baseline: 1.003 ms | change: +5.726 ms)*
**Scan Type:** Seq Scan + Index Scan
**Index Used:** idx_income_ssn

```
    EXPLAIN ANALYZE
    SELECT p.name, i.annual_income
    FROM person p
    JOIN get_fit_now_member m ON p.id = m.person_id
    JOIN income i ON p.ssn = i.ssn
    WHERE m.membership_status = 'gold';
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 7.779 ms *(baseline: 0.336 ms | change: +7.443 ms)*
**Scan Type:** Bitmap Heap Scan + Index Scan
**Index Used:** idx_license_hair_car, idx_person_license

```
EXPLAIN ANALYZE
SELECT p.name
FROM person p
JOIN facebook_event_checkin f
ON p.id = f.person_id
WHERE f.date BETWEEN 20180101 AND 20181231;
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 2.127 ms *(baseline: 3.610 ms | change: -1.483 ms)*
**Scan Type:** Bitmap Heap Scan + Index Scan
**Index Used:** idx_license_hair_car, idx_person_license

```
    EXPLAIN ANALYZE
    SELECT p.name
    FROM person p
    JOIN drivers_license d
    ON p.license_id = d.id
    WHERE d.hair_color = 'red'
    AND d.car_make = 'Tesla';
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 8.565 ms *(baseline: 7.480 ms | change: +1.085 ms)*
**Scan Type:** Seq Scan
**Index Used:** None

```
    EXPLAIN ANALYZE
    SELECT *
    FROM interview
    WHERE transcript ILIKE '%gym%'
    OR transcript ILIKE '%murder%';
```

---

## Q8 — Average income by car make

**Execution Time:** 9.277 ms *(baseline: 7.702 ms | change: +1.575 ms)*
**Scan Type:** Sequential Scan
**Index Used:** None (planner chose Seq Scan)

```
EXPLAIN ANALYZE
SELECT d.car_make, AVG(i.annual_income)
FROM drivers_license d
JOIN person p ON d.id = p.license_id
JOIN income i ON p.ssn = i.ssn
GROUP BY d.car_make;
```
### NOTE FROM BATOOL: Although indexes were added on join columns, PostgreSQL continued using Sequential Scans because the query processes a large percentage of each table. For aggregation queries over most rows, sequential scanning is more efficient than index lookups.