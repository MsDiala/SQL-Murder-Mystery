# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.184 ms
**Scan Type:** Sequential Scan
**Join Method:** None

```
    EXPLAIN ANALYZE
    SELECT *
    FROM crime_scene_report
    WHERE type = 'murder'
    AND city = 'SQL City';
```

---

## Q2 — People with their driver's license details

**Execution Time:** 7.582 ms
**Scan Type:** Sequential Scan
**Join Method:** Hash Join

```
    EXPLAIN ANALYZE
    SELECT p.name, p.address_number, p.address_street_name, d.age, d.car_make, d.car_model
    FROM person p
    JOIN drivers_license d
    ON p.license_id = d.id;

```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.315 ms
**Scan Type:** Sequential Scan
**Join Method:** Hash Join
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

**Execution Time:** 1.003 ms
**Scan Type:** Sequential Scan
**Join Method:** Hash Join

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

**Execution Time:** 0.336 ms
**Scan Type:** Sequential Scan
**Join Method:** Hash Join

```
    EXPLAIN ANALYZE
    SELECT p.name, f.event_name, f.date
    FROM person p
    JOIN facebook_event_checkin f
    ON p.id = f.person_id
    WHERE f.date BETWEEN 20180101 AND 20181231;
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 3.610 ms
**Scan Type:** Sequential Scan
**Join Method:** Hash Join

```
    EXPLAIN ANALYZE
    SELECT p.name, d.hair_color, d.car_make
    FROM person p
    JOIN drivers_license d
    ON p.license_id = d.id
    WHERE d.hair_color = 'red'
    AND d.car_make = 'Tesla';
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 7.480 ms
**Scan Type:** Sequential Scan
**Join Method:** None
```
    EXPLAIN ANALYZE
    SELECT *
    FROM interview
    WHERE transcript ILIKE '%gym%'
    OR transcript ILIKE '%murder%';
```

---

## Q8 — Average income by car make

**Execution Time:** 7.702 ms
**Scan Type:** Sequential Scan
**Join Method:** Hash Join

```
    EXPLAIN ANALYZE
    SELECT d.car_make, AVG(i.annual_income)
    FROM person p
    JOIN drivers_license d ON p.license_id = d.id
    JOIN income i ON p.ssn = i.ssn
    GROUP BY d.car_make;

```
