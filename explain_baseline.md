# explain_baseline.md — Before Indexing (PostgreSQL)

> Run each query with `EXPLAIN ANALYZE` and record the execution plan details.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.138 ms
**Scan Type:** Seq Scan
**Notes:** Full table scan on `crime_scene_report`; 1225 rows filtered out.

```
Sort
 -> Seq Scan on crime_scene_report
```

---

## Q2 — People with their driver's license details

**Execution Time:** 21.441 ms
**Scan Type:** Seq Scan (person, drivers_license)
**Join Type:** Hash Join
**Notes:** No filtering; query returns most rows → sequential scan is expected.

```
Hash Join
 -> Seq Scan on person
 -> Seq Scan on drivers_license
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 1.098 ms
**Scan Type:** Seq Scan (get_fit_now_check_in)
**Join Type:** Hash Join
**Notes:** Filter on `check_in_date` caused scanning entire table; 2693 rows removed.

```
Hash Join
 -> Seq Scan on get_fit_now_check_in
 -> Seq Scan on get_fit_now_member
```

---

## Q4 — Gold gym members and their income

**Execution Time:** ~1.25 ms
**Scan Type:** Seq Scan (get_fit_now_member)
**Join Type:** Nested Loop + Hash Join
**Notes:** Small table; filtering on `membership_status` but table size is small.

```
Nested Loop
 -> Hash Join
    -> Seq Scan on person
    -> Seq Scan on get_fit_now_member
 -> Index Scan on income
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** ~6.15 ms
**Scan Type:** Seq Scan (facebook_event_checkin)
**Join Type:** Hash Join
**Notes:** Range filter on date; many rows scanned (~20000).

```
Hash Join
 -> Seq Scan on facebook_event_checkin
 -> Seq Scan on person
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** ~0.94 ms
**Scan Type:** Seq Scan (drivers_license)
**Join Type:** Nested Loop
**Notes:** Filter on hair_color + car_make; scanned entire table (~10000 rows).

```
Nested Loop
 -> Seq Scan on drivers_license
 -> Index Scan on person
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** ~7.06 ms
**Scan Type:** Seq Scan (interview)
**Join Type:** Nested Loop
**Notes:** `ILIKE '%...%'` prevents index usage; full scan required.

```
Nested Loop
 -> Seq Scan on interview
 -> Index Scan on person
```

---

## Q8 — Average income by car make

**Execution Time:** ~14.36 ms
**Scan Type:** Seq Scan (person, income, drivers_license)
**Join Type:** Hash Join
**Notes:** Aggregation + GROUP BY; full scans expected.

```
Hash Aggregate
 -> Hash Join
    -> Hash Join
       -> Seq Scan on person
       -> Seq Scan on income
    -> Seq Scan on drivers_license
```
